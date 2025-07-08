defmodule NextGearMotorsWeb.RateLimiter do
  @moduledoc """
  Central rate limiter for next gear motors.

  Uses [hammer](https://github.com/ExHammer/hammer) to properly rate limit the application.
  """

  use Hammer, backend: :ets
end
