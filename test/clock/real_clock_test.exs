defmodule Clock.RealClockTest do
  use ExUnit.Case, async: true

  alias Clock
  alias Clock.RealClock

  setup do
    clock = %RealClock{}
    [clock: clock]
  end

  test ".now/1 returns a datetime", context do
    assert abs(DateTime.diff(Clock.now(context.clock), DateTime.utc_now())) < 1000
  end
end
