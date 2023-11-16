defmodule HousekeepingBook.Schema.Category do
  use HousekeepingBook.Schema.Base

  schema "categories" do
    field :name, :string
    field :type, :string
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end
end
