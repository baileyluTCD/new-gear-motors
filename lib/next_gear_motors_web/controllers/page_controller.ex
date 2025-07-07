defmodule NextGearMotorsWeb.PageController do
  use NextGearMotorsWeb, :controller

  def home(conn, _params) do
    :telemetry.execute([:next_gear_motors], %{visits: 1})

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def contact(conn, _params), do: render(conn, :contact)
  def about(conn, _params), do: render(conn, :about)
  def privacy(conn, _params), do: render(conn, :privacy)
  def cookies(conn, _params), do: render(conn, :cookies)
  def not_found(conn, _params), do: render(conn, :not_found)
end
