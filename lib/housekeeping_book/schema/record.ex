defmodule HousekeepingBook.Schema.Record do
  use HousekeepingBook.Schema.Base

  alias HousekeepingBook.Schema.User
  alias HousekeepingBook.Schema.Category

  schema "records" do
    field :date, :utc_datetime
    field :description, :string
    field :amount, :integer

    field :payment, Ecto.Enum,
      values: [:cash, :check_card, :credit_card, :bank_transfer, :pay, :other]

    timestamps(type: :utc_datetime)

    belongs_to :subject, User
    belongs_to :category, Category, on_replace: :delete

    field :tag_ids, {:array, :id}
    field :tags, {:array, :map}, virtual: true
  end
end
