defmodule Clock.RealClock do
  @moduledoc false
  defstruct []

  defimpl Clock do
    def now(_clock), do: DateTime.utc_now()

    def send_after(_clock, destination, message, duration) do
      {:ok, ref} = :timer.send_after(duration, destination, message)
      ref
    end

    def send_interval(_clock, destination, message, duration) do
      {:ok, ref} = :timer.send_interval(duration, destination, message)
      ref
    end

    def cancel(_clock, tref) do
      {:ok, _} = :timer.cancel(tref)
      :ok
    end
  end
end
