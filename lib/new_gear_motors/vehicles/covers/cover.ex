defmodule NewGearMotors.Vehicles.Covers.Cover do
  @moduledoc """
  # Vehicle Cover Schema

  A `Cover` is the displayable image associated with a vehicle
  """
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extensions ~w(.jpg .jpeg .gif .png .avif)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extensions, file_extension) do
      true -> :ok
      false -> {:error, "file type is invalid"}
    end
  end

  def transform(:original, _) do
    {:convert, "-format avif", :avif}
  end

  def filename(_version, {file, _scope}) do
    hash = :crypto.hash(:sha256, file.file_name) |> Base.encode16()
    file_title = file.file_name |> Path.rootname() |> String.downcase()

    "#{file_title}-#{hash}"
  end
end
