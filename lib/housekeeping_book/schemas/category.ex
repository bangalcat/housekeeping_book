defmodule HousekeepingBook.Schema.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :type, :string
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
  end
end
