defmodule NextGearMotorsWeb.CSP do
  @moduledoc """
  Contains functions used for producing the applications nonce
  """
  require Logger

  import NextGearMotorsWeb.CSP.Macros

  csp do
    %{
      "default-src" => "'self'",
      "style-src-elem" => "'self' fonts.googleapis.com",
      "script-src-elem" => "'self'",
      "font-src" => "'self' fonts.gstatic.com",
      "img-src" => "'self' data: <asset_host>"
    }
  end
end
