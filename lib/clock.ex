defprotocol Clock do
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
