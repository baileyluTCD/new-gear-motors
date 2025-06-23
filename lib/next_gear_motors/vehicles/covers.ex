defmodule NextGearMotors.Vehicles.Covers do
  @moduledoc """
  The Vehicles Covers context.
  """

  import Ecto.Query, warn: false
  alias NextGearMotors.Repo

  alias NextGearMotors.Vehicles.Covers.Cover

  @doc """
  Returns the list of covers.

  ## Examples

      iex> list_covers()
      [%Cover{}, ...]

  """
  def list_covers do
    Repo.all(Cover)
  end
end
