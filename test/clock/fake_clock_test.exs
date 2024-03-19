defmodule Clock.FakeClockTest do
  use ExUnit.Case, async: true

  alias Clock
  alias Clock.FakeClock

  setup do
    clock = FakeClock.new()

    [clock: clock]
  end

  test ".now/1 returns a datetime", context do
    assert %DateTime{} = Clock.now(context.clock)
  end

  test "can travel without any listeners", context do
    before_travel = Clock.now(context.clock)
    FakeClock.travel(context.clock, 1000)
    after_travel = Clock.now(context.clock)
    assert after_travel == DateTime.add(before_travel, 1000, :millisecond)
  end

  test "fake clock allows you to traverse time", context do
    Clock.send_interval(context.clock, self(), :message, 1)

    before_travel = Clock.now(context.clock)

    FakeClock.travel(context.clock, 3)

    after_travel = Clock.now(context.clock)
    assert after_travel == DateTime.add(before_travel, 3, :millisecond)

    assert_receive :message
    assert_receive :message
    assert_receive :message
    refute_receive :message, 10
  end

  test "fake clock allows you to do multiple send_afters", context do
    Clock.send_after(context.clock, self(), :one, 1)
    Clock.send_after(context.clock, self(), :two, 2)
    refute_receive :one
    refute_receive :two

    FakeClock.travel(context.clock, 2)
    assert_receive :one
    assert_receive :two
  end

  test "fake clock allows you to cancel", context do
    ref1 = Clock.send_after(context.clock, self(), :interval_message, 10)
    ref2 = Clock.send_after(context.clock, self(), :interval_message, 10)
    Clock.cancel(context.clock, ref1)
    Clock.cancel(context.clock, ref2)
    FakeClock.travel(context.clock, 100)
    refute_receive _, 10
  end
end
