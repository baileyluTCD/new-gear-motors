defmodule NextGearMotors.Vehicles.Covers.Cover do
  @moduledoc """
  # Vehicle Cover Schema

  A `Cover` is the displayable image associated with a vehicle
  """
  use Waffle.Definition
  use Waffle.Ecto.Definition

  alias NextGearMotors.Vehicles.Vehicle

  alias Vix.Vips.{Image, Operation}

  require Logger

  @versions [:original]
  @extensions ~w(.png .jpg .jpeg)

  def validate({%Waffle.File{} = file, _}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    case Enum.member?(@extensions, file_extension) do
      true ->
        :ok

      false ->
        {:error,
         "file extension is not supported - accepted extensions: #{inspect(@extensions, pretty: true)}"}
    end
  end

  def transform(:original, _), do: {&process/2, fn _, _ -> :webp end}

  def process(_version, file) do
    tmp_path = Waffle.File.generate_temporary_path("webp")

    with {:ok, image} <- Image.new_from_file(file.path),
         :ok <- Operation.webpsave(image, tmp_path) do
      ret = {
        :ok,
        %Waffle.File{
          file
          | path: tmp_path,
            is_tempfile?: true,
            file_name: "#{Path.rootname(file.file_name)}.webp"
        }
      }

      Logger.warn("ret: #{inspect(ret)}")

      ret
    end
  end

  def filename(_version, {%{file_name: file_name}, %Vehicle{} = vehicle}) do
    "vehicle-#{vehicle.id}$cover-#{Path.rootname(file_name)}$"
  end
end
