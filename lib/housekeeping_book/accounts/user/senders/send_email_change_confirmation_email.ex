defmodule HousekeepingBook.Accounts.User.Senders.SendEmailChangeConfirmationEmail do
  use AshAuthentication.Sender

  @impl true
  def send(user, token, _opts) do
    url = HousekeepingBook.Accounts.web_paths().new_user_confirm_url(token)

    HousekeepingBook.Accounts.UserNotifier.deliver_confirmation_instructions(
      user,
      url
    )
  end
end
