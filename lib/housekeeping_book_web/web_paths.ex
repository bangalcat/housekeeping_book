defmodule HousekeepingBookWeb.WebPaths do
  use HousekeepingBookWeb, :verified_routes

  @behaviour HousekeepingBook.Accounts.WebPaths

  @impl true
  def user_reset_password_path(token) do
    url(~p"/auth/reset/#{token}")
  end
end
