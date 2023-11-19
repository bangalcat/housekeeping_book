defmodule HousekeepingBook.Schema.UserToken do
  use HousekeepingBook.Schema.Base

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, HousekeepingBook.Schema.User

    timestamps(updated_at: false)
  end
end
