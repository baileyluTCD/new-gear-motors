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
      def csp() do
        asset_host = Application.get_env(:waffle, :asset_host)

        unquote(csp_string) |> String.replace("<asset_host>", asset_host || "")
      end
    end
  end
end
