defmodule NextGearMotors.Reservations.Messages.Message do
  @moduledoc """
  # Message Schema

  The database type for a given message
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NextGearMotorsWeb.RateLimiter

  @max_messages_per_hour 25
  @hour :timer.hours(1)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    belongs_to :from, NextGearMotors.Accounts.User
    belongs_to :reservation, NextGearMotors.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :from_id, :reservation_id])
    |> assoc_constraint(:from)
    |> assoc_constraint(:reservation)
    |> validate_required([:text, :from_id, :reservation_id])
    |> validate_length(:text, min: 1, max: 255)
  end

  def create_changeset(message, attrs) do
    changeset(message, attrs)
    |> validate_rate()
  end

  defp validate_rate(message) do
    case fetch_field(message, :from_id) do
      {_, nil} ->
        add_error(
          message,
          :rate_limiting,
          "this user id is invalid hence is not a candiate for rate limiting"
        )

      {_, from_id} ->
        check_rate(message, from_id)

      _ ->
        add_error(
          message,
          :rate_limiting,
          "this message does not have a user id associated with it and hence is not a candiate for rate limiting"
        )
    end
  end

  defp check_rate(message, from_id) do
    key = "send-message:#{from_id}"

    case RateLimiter.hit(key, @hour, @max_messages_per_hour) do
      {:allow, _current_count} ->
        message

      {:deny, ms_until_next_window} ->
        add_error(
          message,
          :rate_limiting,
          "you may only send a maximum of #{@max_messages_per_hour} messages per hour. you may send messages again in #{ms_until_next_window}ms."
        )
    end
  end
end
