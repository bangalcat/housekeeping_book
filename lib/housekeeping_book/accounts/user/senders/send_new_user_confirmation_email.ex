defmodule HousekeepingBook.Accounts.User.Senders.SendNewUserConfirmationEmail do
  use AshAuthentication.Sender

  @impl true
  def send(user, token, _opts) do
    url = HousekeepingBook.Accounts.web_paths().new_user_confirmation_path(token)

    HousekeepingBook.Accounts.UserNotifier.deliver_confirmation_instructions(
      user,
      url
    )
  end
end
