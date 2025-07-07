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
    nonce = generate_nonce()

    conn
    |> Plug.Conn.assign(:csp_nonce, nonce)
    |> put_secure_browser_headers(%{"content-security-policy" => csp(nonce)})
  end
end
