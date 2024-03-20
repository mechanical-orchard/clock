defprotocol Clock do
  @moduledoc """
  A simple clock protocol for time traveling in tests.

  In your code, hold onto a clock struct and use the protocol for all things time related.

  ```
  clock = %Clock.RealClock{}
  ...
  now = Clock.now(clock)
  ```

  In tests, make sure the clock struct is a `FakeClock` and use it to time travel.

  ```
  clock = %Clock.FakeClock{}
  ...
  now = Clock.now(clock)
  Clock.FakeClock.travel(clock, 60_000)
  one_minute_later = Clock.now(clock)
  ```
  """
  @type tref :: term()

  @spec now(t()) :: DateTime.t()
  def now(clock)

  @spec send_after(t(), pid() | atom(), term(), non_neg_integer()) :: tref()
  def send_after(clock, destination, message, duration_in_ms)

  @spec send_interval(t(), pid() | atom(), term(), non_neg_integer()) :: tref()
  def send_interval(clock, destination, message, interval_in_ms)

  @spec cancel(t(), tref()) :: :ok
  def cancel(clock, tref)
end
