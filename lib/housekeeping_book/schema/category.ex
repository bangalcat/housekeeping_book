defmodule HousekeepingBook.Schema.Category do
  use HousekeepingBook.Schema.Base

  schema "categories" do
    field :name, :string
    field :type, Ecto.Enum, values: [:income, :expense, :saving]

    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps(type: :utc_datetime)
  end

  def new(attrs \\ %{}) do
    struct!(__MODULE__, attrs)
  end

  def category_type_name(:income), do: "수입"
  def category_type_name(:expense), do: "지출"
  def category_type_name(:saving), do: "저축"
end
