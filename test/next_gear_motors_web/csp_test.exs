defmodule NextGearMotorsWeb.CSPTest do
  import NextGearMotorsWeb.CSP

  use ExUnit.Case, async: true

  describe "Content Security Policy" do
    test "csp/0 forbids insecure access" do
      csp = csp()

      assert csp =~ "default-src 'self';"
    end

    test "csp/0 uses asset_host" do
      original = Application.get_env(:waffle, :asset_host)
      on_exit(fn -> Application.put_env(:waffle, :asset_host, original) end)

      System.put_env("AWS_ENDPOINT_URL_S3", "http://mocked.asset.host")

      Application.put_env(:waffle, :asset_host, {:system, "AWS_ENDPOINT_URL_S3"})
      csp = csp()

      assert csp =~ "http://mocked.asset.host"
    end
  end
end
