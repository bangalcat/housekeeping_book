defmodule HousekeepingBook.Households do
  use Ash.Domain
  use Boundary, deps: [HousekeepingBook.Repo], exports: [Record, Subject, Category, Tag]

  require Logger
  require Ash.Query
  import Ecto.Query

  alias HousekeepingBook.Households.Category
  alias HousekeepingBook.Households.CategoryType
  alias HousekeepingBook.Households.Record
  alias HousekeepingBook.Households.RecordTag
  alias HousekeepingBook.Households.Subject
  alias HousekeepingBook.Households.Tag

  resources do
    resource Record do
      define :monthly_records, args: [:date_month, {:optional, :timezone}]

      define :get_record, action: :read, get_by: :id

      define :get_nearest_date_record,
        args: [:date, {:optional, :timezone}],
        get?: true

      define :get_record_amount_by_day_and_type,
        action: :amount_by_day_and_type,
        args: [:date_month, {:optional, :timezone}]

      define :create_record, action: :create
      define :update_record, action: :update
      define :delete_record, action: :destroy
    end

    resource Subject

    resource Category do
      define :get_category_by_name_and_type, action: :by_name_and_type, args: [:name, :type]

      define :top_categories
      define :child_categories, args: [:id]
      define :list_categories, action: :read

      define :delete_category, action: :destroy
      define :bottom_categories
      define :create_category, action: :create
      define :update_category, action: :update
    end

    resource Tag do
      define :list_tags, action: :read
      define :get_by_id, action: :read, get_by: :id
      define :create_tag, action: :create
      define :update_tag, action: :update
      define :delete_tag, action: :destroy
    end

    resource RecordTag
  end

  def get_category!(id) do
    Ash.get!(Category, id)
  end

  def leaf_category?(category) do
    Category
    |> Ash.Query.filter(parent_id == ^category.id)
    |> Ash.exists?()
    |> Kernel.not()
  end

  def get_records_amount_sum_group_by_date_and_type(date_month, timezone \\ "UTC") do
    Record
    |> Ash.Query.for_read(:monthly_records, date_month: date_month, timezone: timezone)
    |> Ash.Query.data_layer_query()
    |> elem(1)
    |> join(:left, [r], c in assoc(r, :category))
    |> select(
      [r, c],
      {{fragment(
          "(date_trunc('day', ? AT TIME ZONE 'Z' AT TIME ZONE ?::varchar))",
          r.date,
          ^timezone
        )
        |> type(:date)
        |> selected_as(:day), c.type}, type(sum(r.amount), :integer)}
    )
    |> group_by([r, c], [selected_as(:day), c.type])
    |> exclude(:order_by)
    |> HousekeepingBook.Repo.all()
    |> Map.new()
  end

  def with_total(%{} = records_map) do
    total =
      records_map
      |> Enum.reduce(%{expense: 0, income: 0}, fn {key, value}, acc ->
        case key do
          {_, :expense} ->
            Map.update(acc, :expense, value, &(&1 + value))

          {_, :income} ->
            Map.update(acc, :income, value, &(&1 + value))
        end
      end)

    {records_map, total}
  end

  def cast_datetime_with_timezone(date, timezone) do
    with date when date != nil <- date,
         {:ok, ndate} <- Ecto.Type.cast(:naive_datetime, date),
         {:ok, datetime} <- DateTime.from_naive(ndate, timezone),
         {:ok, datetime} <- DateTime.shift_zone(datetime, "Etc/UTC") do
      datetime
    else
      nil ->
        nil

      error ->
        Logger.error("date cast error: #{inspect(error)}")
        nil
    end
  end

  @spec category_type_options() :: [{String.t(), atom()}]
  def category_type_options() do
    CategoryType.values()
    |> Enum.map(&{CategoryType.category_type_name(&1), &1})
  end

  @spec record_payment_options() :: [{String.t(), atom()}]
  def record_payment_options do
    __MODULE__.PaymentType.values()
    |> Enum.map(&{__MODULE__.PaymentType.description(&1), &1})
  end

  def record_payment_name(value) do
    __MODULE__.PaymentType.description(value)
  end
end
