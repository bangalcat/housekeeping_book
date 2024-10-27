defmodule HousekeepingBookWeb.WebPaths do
  use HousekeepingBookWeb, :verified_routes

  @behaviour HousekeepingBook.Accounts.WebPaths

  @impl true
  def user_reset_password_path(token) do
    url(~p"/auth/reset/#{token}")
  end

  @impl true
  def new_user_confirmation_path(token) do
    url(~p"/auth/user/confirm_new_user?#{[confirm: token]}")
  end
end
