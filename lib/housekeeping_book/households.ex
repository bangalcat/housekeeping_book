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
    resource Record
    resource Subject
    resource Category
    resource Tag
    resource RecordTag
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
end
