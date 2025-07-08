defmodule NextGearMotors.Accounts.UserNotifier do
  @moduledoc """
  # User Notifier

  This module contains functions for sending emails to a user based on
  actions such as resetting their password, etc
  """

  import NextGearMotorsWeb.VehicleHelper
  alias NextGearMotors.Reservations.Messages

  @notice """

  NOTICE: This message was automatically generated and this mailbox is not monitored. Please check 'https://nextgearmotors.ie/contact' for up to date contact information.

  """

  import Swoosh.Email

  alias NextGearMotors.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"NextGear Motors", "nextgearmotors@zohomail.eu"})
      |> subject(subject)
      |> text_body(body <> @notice)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver a sent message in the form of an email.
  """
  def deliver_sent_message(message) do
    message = Messages.preload_from(message)

    deliver(message.from.email, "Your Reservation - New Message", """

    ==============================

    Hi #{message.from.email},

    You have one new message relating to one of your reservations:

    #{shorten_text(message.text)}

    Read the rest on 'https://nextgearmotors.ie'.

    ==============================
    """)
  end
end
