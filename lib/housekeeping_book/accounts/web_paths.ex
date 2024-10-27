defmodule HousekeepingBook.Accounts.WebPaths do
  @callback user_reset_password_path(token :: String.t()) :: String.t()
  @callback new_user_confirmation_path(token :: String.t()) :: String.t()
  @callback user_confirmation_path(token :: String.t()) :: String.t()
end
