defmodule NextGearMotorsWeb.Plugs.CSP do
  @moduledoc false
  @doc """
  This plug adds Phoenix secure HTTP headers including a
  “Content-Security-Policy” header to responses.
  """

  import NextGearMotorsWeb.CSP

  @behaviour Plug

  import Phoenix.Controller, only: [put_secure_browser_headers: 2]

  def init(opts), do: opts

  def call(conn, _) do
    put_secure_browser_headers(conn, %{"content-security-policy" => csp()})
  end
end
