defmodule HousekeepingBook.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use Ash.Domain

  use Boundary,
    deps: [HousekeepingBook.Repo, HousekeepingBook.Schema, HousekeepingBook.Mailer],
    exports: [User, UserToken, WebPaths]

  resources do
    resource HousekeepingBook.Accounts.User do
      define :get_user_by_id, action: :read, get_by: :id
      define :delete_user, action: :destroy
      define :list_users
      define :update_user, action: :update
      define :update_user_email, action: :update_email
      define :update_user_password, action: :update_password
      define :register_user_with_password, action: :register_with_password
      define :create_shared_user, action: :create_shared
      define :create_user, action: :create
    end

    resource HousekeepingBook.Accounts.UserToken
    resource HousekeepingBook.Accounts.Token
  end

  ######################################

  def web_paths do
    Application.fetch_env!(:housekeeping_book, HousekeepingBook.Accounts.WebPaths)
  end
end
