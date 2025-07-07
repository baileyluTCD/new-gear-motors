defmodule NextGearMotorsWeb.CSP.Macros do
  @moduledoc """
  Contains macros used for producing the applications nonce
  """

  defmacro csp(do: directives_ast) do
    {directives, _bindings} = Code.eval_quoted(directives_ast, [], __CALLER__)

    csp_string =
      directives
      |> Enum.map_join("; ", fn {k, v} -> "#{k} #{v}" end)

    quote do
      @doc """
      Produces the application's content security policy.

      If `<asset_host>` is included in the string it will be interpolated to the value of the waffle asset host set at runtime.
      """
      def csp(nonce) when is_binary(nonce) do
        config = Application.get_env(:waffle, :asset_host)

        unquote(csp_string)
        |> interpolate_host(config)
        |> String.replace("<nonce>", nonce)
      end

      defp interpolate_host(csp_string, {_, asset_host_var}) do
        asset_host = System.get_env(asset_host_var)

        csp_string |> String.replace("<asset_host>", asset_host)
      end

      defp interpolate_host(csp_string, nil),
        do:
          csp_string
          |> String.replace("<asset_host>", "")
    end
  end
end
