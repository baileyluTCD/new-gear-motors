defmodule NewGearMotors.Vehicles.Cover do
  @moduledoc """
  # Vehicle Cover Schema

  A `Cover` is the displayable image associated with a vehicle
  """
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :thumb]
  @extensions ~w(.jpg .jpeg .gif .png .avif)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extensions, file_extension) do
      true -> :ok
      false -> {:error, "file type is invalid"}
    end
  end

  def transform(:thumb, _) do
    {:convert, "", :avif}
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_, {_file, user}) do
    "uploads/avatars/#{user.id}"
  end
end
