defmodule NewGearMotorsWeb.VehicleHelper do
  @moduledoc """
  Helper functions for the vehicles liveview
  """

  @doc """
  Shortens a piece of text down to a side appropriate for the ui

  ## Examples

      iex> NewGearMotorsWeb.VehicleHelper.shorten_text("Hello World")
      "Hello World"

      iex> NewGearMotorsWeb.VehicleHelper.shorten_text("Hello World", 5)
      "Hello..."

      iex> NewGearMotorsWeb.VehicleHelper.shorten_text("This is a very long string that needs to be shortened", 10)
      "This is a ..."

  """
  def shorten_text(text, length \\ 50) when is_binary(text) do
    if String.length(text) <= length do
      text
    else
      String.slice(text, 0, length) <> "..."
    end
  end
end
