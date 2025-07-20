defmodule NextGearMotorsWeb.CSP do
  @moduledoc """
  Contains functions used for producing the applications nonce
  """

  import NextGearMotorsWeb.CSP.Macros

  csp do
    %{
      "default-src" => "'self'",
      "style-src-elem" => "'self' fonts.googleapis.com 'nonce-<nonce>'",
      "script-src-elem" => "'self' 'nonce-<nonce>'",
      "font-src" => "'self' data: fonts.gstatic.com",
      "img-src" => "'self' blob: data: <asset_host>"
    }
  end

  def generate_nonce(size \\ 24),
    do:
      size
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)
end
