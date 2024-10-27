defmodule HousekeepingBook.Accounts.User.Senders.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """

  use AshAuthentication.Sender

  @impl true
  def send(user, token, _opts) do
    url = HousekeepingBook.Accounts.web_paths().user_reset_password_path(token)

    HousekeepingBook.Accounts.UserNotifier.deliver_reset_password_instructions(
      user,
      url
    )
  end
end
