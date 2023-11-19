defmodule HousekeepingBook.Schema.Record do
  use HousekeepingBook.Schema.Base

  alias HousekeepingBook.Schema.User
  alias HousekeepingBook.Schema.Category

  @derive {
    Flop.Schema,
    filterable: [:date, :amount, :payment, :tags, :category_name, :category_type, :subject_name],
    sortable: [:date, :amount, :payment],
    default_limit: 30,
    adapter_opts: [
      join_fields: [
        category_name: [
          binding: :category,
          field: :name,
          ecto_type: :string
        ],
        category_type: [
          binding: :category,
          field: :type,
          ecto_type: :string
        ],
        subject_name: [
          binding: :subject,
          field: :name,
          ecto_type: :string
        ]
      ]
    ]
  }

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
