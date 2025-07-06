defmodule NextGearMotorsWeb.PageController do
  use NextGearMotorsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def contact(conn, _params), do: render(conn, :contact)
  def about(conn, _params), do: render(conn, :about)
  def privacy(conn, _params), do: render(conn, :privacy)
end
