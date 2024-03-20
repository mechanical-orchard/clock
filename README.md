# Clock

## Installation

Add the package to your `mix.exs` dependencies:

```
  {:clock, "~> 0.1"}
```

## Usage

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