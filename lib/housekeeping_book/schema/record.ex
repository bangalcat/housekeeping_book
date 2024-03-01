defmodule HousekeepingBook.Schema.Record do
  use HousekeepingBook.Schema.Base

  alias HousekeepingBook.Schema.User
  alias HousekeepingBook.Schema.Category

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
