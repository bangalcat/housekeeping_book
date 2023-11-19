defmodule HousekeepingBook.Schema.User do
  use HousekeepingBook.Schema.Base

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    field :type, Ecto.Enum, values: [:shared, :normal, :admin], default: :normal

    timestamps(type: :utc_datetime)
  end
end
