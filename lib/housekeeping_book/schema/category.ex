defmodule HousekeepingBook.Schema.Category do
  use HousekeepingBook.Schema.Base

  schema "categories" do
    field :name, :string
    field :type, Ecto.Enum, values: [:income, :expense, :saving]
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end
end
