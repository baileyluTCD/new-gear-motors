defmodule NextGearMotors.Reservations.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias NextGearMotors.Repo
  alias NextGearMotors.Reservations.Messages.Message
  alias NextGearMotors.Accounts.UserNotifier

  @doc """
  Returns the list of messages sorted by the time they were sent at.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Message
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of messages for a reservation.

  ## Examples

      iex> list_messages_for_reservation_id(reservation_id)
      [%Message{}, ...]

  """
  def list_messages_for_reservation_id(reservation_id) do
    query =
      from message in Message,
        where:
          message.reservation_id ==
            ^reservation_id,
        preload: [:from]

    Repo.all(query)
  end

  @doc """
  Preloads a messages's from field

  ## Examples

      iex> preload_from(message)
      [%Message{}, ...]

  """
  def preload_from(message), do: Repo.preload(message, :from)

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    insert =
      %Message{}
      |> Message.create_changeset(attrs)
      |> Repo.insert()

    with {:ok, message} <- insert do
      UserNotifier.deliver_sent_message(message)

      insert
    end
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
