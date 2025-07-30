defmodule NextGearMotors.Vehicles.Covers.Cover.Macros do
  @moduledoc """
  Contains macros used for producing the applications nonce
  """

  defmacro args(do: directives_ast) do
    {raw_args, _bindings} = Code.eval_quoted(directives_ast, [], __CALLER__)

    args =
      raw_args
      |> Enum.map(&to_arg_list/1)
      |> Enum.concat()

    quote do
      defp args(old_path, new_path) do
        [
          "convert",
          "#{old_path}"
        ] ++
          unquote(args) ++
          [
            "#{new_path}"
          ]
      end
    end
  end

  defp to_arg_list(arg) when is_binary(arg), do: [arg]
  defp to_arg_list({arg, val}) when is_binary(arg) and is_binary(val), do: [arg, val]
end
