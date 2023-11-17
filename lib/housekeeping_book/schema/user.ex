defmodule HousekeepingBook.Schema.User do
  use HousekeepingBook.Schema.Base

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end
end
