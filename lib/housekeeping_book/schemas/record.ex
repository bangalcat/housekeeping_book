defmodule HousekeepingBook.Schema.Record do
  use Ecto.Schema
  import Ecto.Changeset

  alias HousekeepingBook.Schema.User
  alias HousekeepingBook.Schema.Category

  schema "records" do
    field :date, :utc_datetime
    field :description, :string
    field :amount, :integer

    timestamps(type: :utc_datetime)

    belongs_to :subject, User
    belongs_to :category, Category

    field :tag_ids, {:array, :id}
    field :tags, {:array, :map}, virtual: true
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:amount, :description, :date])
    |> validate_required([:amount, :description, :date])
  end
end
