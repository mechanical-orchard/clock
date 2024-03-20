defmodule Clock.FakeClock do
  @moduledoc false
  use GenServer

  alias Clock.FakeClock

  defstruct [:pid]

  @type t :: %__MODULE__{pid: pid()}

  def new(initial_datetime \\ DateTime.utc_now()) do
    {:ok, pid} = GenServer.start_link(__MODULE__, initial_datetime)
    %FakeClock{pid: pid}
  end

  def shutdown(%FakeClock{pid: pid}) do
    GenServer.stop(pid)
  end

  def shutdown(fake_clock_pid) when is_pid(fake_clock_pid) do
    GenServer.stop(fake_clock_pid)
  end

  @spec travel(t(), non_neg_integer()) :: :ok
  def travel(clock, amount_of_time_in_ms) do
    now = Clock.now(clock)
    destination_time = DateTime.add(now, amount_of_time_in_ms, :millisecond)
    travel_loop(clock, destination_time)
    :ok
  end

  defp travel_loop(clock, destination_time) do
    case GenServer.call(clock.pid, {:travel, destination_time}) do
      :done ->
        :ok

      :still_going ->
        travel_loop(clock, destination_time)
    end
  end

  @impl GenServer
  def init(initial_datetime) do
    {:ok, %{timers: [], now: initial_datetime}}
  end

  @impl GenServer
  def handle_call(:now, _from, state) do
    {:reply, state.now, state}
  end

  def handle_call({:send_after, destination, message, duration}, _from, state) do
    tref = make_ref()

    timer =
      %{
        type: :once,
        tref: tref,
        destination: destination,
        message: message,
        next_run: DateTime.add(state.now, duration, :millisecond)
      }

    state = update_in(state.timers, fn timers -> [timer | timers] end)

    {:reply, tref, state}
  end

  def handle_call({:send_interval, destination, message, interval_in_ms}, _from, state) do
    tref = make_ref()

    timer =
      %{
        type: :interval,
        interval_in_ms: interval_in_ms,
        tref: tref,
        destination: destination,
        message: message,
        next_run: DateTime.add(state.now, interval_in_ms, :millisecond)
      }

    state = update_in(state.timers, fn timers -> [timer | timers] end)

    {:reply, tref, state}
  end

  def handle_call({:cancel, tref}, _from, state) do
    {:reply, :ok, cancel(state, tref)}
  end

  def handle_call({:travel, destination_time}, _from, state) do
    case next_events(state) do
      {:ok, upcoming_events, datetime} ->
        if DateTime.compare(datetime, destination_time) == :gt do
          {:reply, :done, %{state | now: destination_time}}
        else
          state = %{state | now: datetime}
          state = execute_events(state, upcoming_events)

          {:reply, :still_going, state}
        end

      :none ->
        {:reply, :done, %{state | now: destination_time}}
    end
  end

  defp execute_events(state, events) do
    Enum.reduce(events, state, fn
      %{type: :interval} = timer, state ->
        send(timer.destination, timer.message)
        state = cancel(state, timer.tref)

        new_timer = %{
          timer
          | next_run: DateTime.add(state.now, timer.interval_in_ms, :millisecond)
        }

        update_in(state.timers, fn timers -> [new_timer | timers] end)

      %{type: :once} = timer, state ->
        send(timer.destination, timer.message)
        cancel(state, timer.tref)
    end)
  end

  defp next_events(state) do
    timestamps =
      state.timers
      |> Enum.map(fn timer -> timer.next_run end)
      |> Enum.sort(DateTime)

    case timestamps do
      [datetime | _rest] ->
        {:ok, Enum.filter(state.timers, fn x -> x.next_run == datetime end), datetime}

      [] ->
        :none
    end
  end

  defp cancel(state, tref) do
    %{
      state
      | timers: Enum.reject(state.timers, fn value -> value.tref == tref end)
    }
  end

  defimpl Clock do
    def now(clock), do: GenServer.call(clock.pid, :now)

    def send_after(clock, destination, message, duration) do
      GenServer.call(clock.pid, {:send_after, destination, message, duration})
    end

    def send_interval(clock, destination, message, duration) do
      GenServer.call(clock.pid, {:send_interval, destination, message, duration})
    end

    def cancel(clock, tref) do
      GenServer.call(clock.pid, {:cancel, tref})
    end
  end
end
