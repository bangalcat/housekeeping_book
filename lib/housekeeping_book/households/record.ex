defmodule HousekeepingBook.Households.Record do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  require Ash.Query

  code_interface do
    define_for HousekeepingBook.Households
    define :monthly_records, args: [:date_month, {:optional, :timezone}]

    define :create
    define :update
    define :delete, action: :destroy

    define :get_nearest_date_record,
      args: [:date, {:optional, :timezone}],
      get?: true

    define :amount_by_day_and_type,
      action: :amount_by_day_and_type,
      args: [:date_month, {:optional, :timezone}]

    define :read_all
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:date, :amount, :description, :payment, :subject_id, :category_id]

      require_attributes [:date, :category_id, :subject_id]
    end

    update :update do
      accept [:id, :date, :amount, :description, :payment, :subject_id, :category_id]

      require_attributes [:date, :category_id, :subject_id]
    end

    read :read_all do
      pagination do
        keyset? true
        default_limit 1000
      end
    end

    read :list_records do
      argument :filters, :map, allow_nil?: true

      pagination do
        keyset? true
        default_limit 1000
      end
    end

    read :amount_by_day_and_type do
      argument :date_month, :term
      argument :timezone, :string, allow_nil?: true, default: "UTC"

      prepare HousekeepingBook.Households.Preparations.DateMonthFilter

      prepare build(
                load: [
                  day: %{timezone: arg(:timezone)},
                  category_type: %{},
                  daily_amount: %{timezone: arg(:timezone)}
                ]
              )

      prepare build(select: [:amount])
    end

    read :monthly_records do
      argument :date_month, :term
      argument :timezone, :string, allow_nil?: true, default: "UTC"

      prepare HousekeepingBook.Households.Preparations.DateMonthFilter
      prepare build(sort: [date: :desc])
      prepare build(load: [:subject, :category, :tags])
    end

    read :get_nearest_date_record do
      argument :date, :date
      argument :timezone, :string, allow_nil?: true, default: "UTC"

      prepare fn query, _context ->
        date = Ash.Query.get_argument(query, :date)
        timezone = Ash.Query.get_argument(query, :timezone)
        start_date = DateTime.new!(date, ~T[00:00:00], timezone)
        end_date = DateTime.new!(Date.end_of_month(date), ~T[23:59:59], timezone)
        Ash.Query.filter(query, date > ^start_date and date <= ^end_date)
      end

      prepare build(sort: [date: :asc], limit: 1)
    end
  end

  calculations do
    calculate :daily_amount,
              :map,
              expr(%{day: day(timezone: arg(:timezone)), type: category_type}) do
      argument :timezone, :string, allow_nil?: true, default: "UTC"
      filterable? false
    end

    calculate :day,
              :date,
              expr(
                fragment(
                  "(date_trunc('day', ? AT TIME ZONE 'Z' AT TIME ZONE ?))",
                  date,
                  ^arg(:timezone)
                )
              ) do
      argument :timezone, :string, allow_nil?: true, default: "UTC"
    end

    calculate :category_type, HousekeepingBook.Households.CategoryType, expr(category.type)
  end

  attributes do
    integer_primary_key :id
    attribute :date, :utc_datetime
    attribute :amount, :integer, default: 0
    attribute :description, :string

    attribute :payment, HousekeepingBook.Households.PaymentType do
      default :other
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :subject, HousekeepingBook.Households.Subject do
      attribute_writable? true
    end

    belongs_to :category, HousekeepingBook.Households.Category do
      attribute_writable? true
    end

    many_to_many :tags, HousekeepingBook.Households.Tag do
      through HousekeepingBook.Households.RecordTag
      source_attribute_on_join_resource :tag_id
      destination_attribute_on_join_resource :record_id
    end
  end

  postgres do
    table "records"
    repo HousekeepingBook.Repo
  end
end
