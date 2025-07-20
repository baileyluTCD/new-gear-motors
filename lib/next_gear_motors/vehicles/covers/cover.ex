defmodule NextGearMotors.Vehicles.Covers.Cover do
  @moduledoc """
  # Vehicle Cover Schema

  A `Cover` is the displayable image associated with a vehicle
  """
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extensions ~w(.png .jpg .jpeg .avif)

  def to_filename(%{filename: name}), do: name
  def to_filename(%{file_name: name}), do: name

  def validate({file, _}) do
    file_extension = to_filename(file) |> Path.extname() |> String.downcase()

    case Enum.member?(@extensions, file_extension) do
      true -> :ok
      false -> {:error, "file type is invalid"}
    end
  end

  def transform(:original, _) do
    {:magick, "-strip -interlace Plane -sampling-factor 4:2:0 -quality 85% -format avif", :avif}
  end

  def filename(_version, {file, _scope}) do
    name = to_filename(file)

    hash = :crypto.hash(:sha256, name) |> Base.encode16()
    file_title = name |> Path.rootname() |> String.downcase()

    "#{file_title}-#{hash}"
  end
end
