defmodule HousekeepingBook.Accounts.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], HousekeepingBook.Accounts.User, _) do
    case Application.fetch_env(:housekeeping_book, :accounts) do
      {:ok, accounts_config} ->
        Keyword.fetch(accounts_config, :signing_secret)

      :error ->
        :error
    end
  end
end
