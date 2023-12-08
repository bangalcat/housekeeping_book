defmodule HousekeepingBook.Schema.Record do
  use HousekeepingBook.Schema.Base

  alias HousekeepingBook.Schema.User
  alias HousekeepingBook.Schema.Category
  alias HousekeepingBook.Flop.CustomFilters

  @derive {
    Flop.Schema,
    filterable: [
      :date,
      :amount,
      :payment,
      :tags,
      :category_id,
      :category_name,
      :category_type,
      :subject_id,
      :date_month
    ],
    sortable: [:date, :amount, :payment],
    default_limit: 20,
    default_order: %{order_by: [:date], order_directions: [:desc, :asc]},
    adapter_opts: [
      custom_fields: [
        date_month: [
          filter: {CustomFilters, :date_month_filter, [source: :date]},
          operators: [:<=, :>=, :==]
        ]
      ],
      join_fields: [
        category_name: [
          binding: :category,
          field: :name,
          ecto_type: :string
        ],
        category_id: [
          binding: :category,
          field: :id,
          ecto_type: :id
        ],
        category_type: [
          binding: :category,
          field: :type,
          ecto_type: :string
        ],
        subject_id: [
          binding: :subject,
          field: :id,
          ecto_type: :id
        ]
      ]
    ]
  }

  schema "records" do
    field :date, :utc_datetime
    field :description, :string
    field :amount, :integer, default: 0

    field :payment, Ecto.Enum,
      values: [:cash, :check_card, :credit_card, :bank_transfer, :pay, :other],
      default: :other

    timestamps(type: :utc_datetime)

    belongs_to :subject, User
    belongs_to :category, Category

    field :tag_ids, {:array, :id}
    field :tags, {:array, :map}, virtual: true
  end

  def new(date \\ DateTime.utc_now()) do
    %__MODULE__{date: date, category: nil, subject: nil}
  end

  def payment_enum_name(nil), do: ""
  def payment_enum_name(:cash), do: "Cash"
  def payment_enum_name(:check_card), do: "Check Card"
  def payment_enum_name(:credit_card), do: "Credit Card"
  def payment_enum_name(:bank_transfer), do: "Bank Transfer"
  def payment_enum_name(:pay), do: "Pay"
  def payment_enum_name(:other), do: "Other"
end
