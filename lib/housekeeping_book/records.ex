defmodule HousekeepingBook.Records do
  @moduledoc """
  The Records context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  require Logger

  alias HousekeepingBook.Repo

  alias HousekeepingBook.Schema.Record
  alias HousekeepingBook.Utils

  @spec get_amount_sum_group_by_date_and_type(map) :: [Record.t()]
  def get_amount_sum_group_by_date_and_type(params \\ %{}) do
    timezone = params[:timezone] || "Etc/UTC"

    from(Record, as: :record)
    |> join(:inner, [record: r], c in assoc(r, :category), as: :category)
    |> select(
      [record: r, category: c],
      {{fragment(
          "(date_trunc('day', ? AT TIME ZONE 'Z') AT TIME ZONE ?)",
          r.date,
          type(^timezone, :string)
        )
        |> type(:date)
        |> selected_as(:day), c.type}, sum(r.amount)}
    )
    |> group_by([record: r, category: c], [selected_as(:day), c.type])
    |> order_by([record: r], selected_as(:day))
    |> query_by_month(params)
    |> Repo.all()
    |> Map.new()
  end

  defp query_by_month(query, %{month_first: %DateTime{} = month_first}) do
    query
    |> where(
      [record: r],
      r.date >= ^month_first and r.date < datetime_add(^month_first, 1, "month")
    )
  end

  defp query_by_month(query, _), do: query

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

  def get_nearest_date_record(%Date{} = date, timezone \\ "Etc/UTC") do
    datetime = DateTime.new!(date, ~T[23:59:00], timezone)
    end_of_month = Date.end_of_month(date) |> DateTime.new!(~T[23:59:59], timezone)

    from(Record, as: :record)
    |> where([r], r.date > ^datetime)
    |> where([r], r.date <= ^end_of_month)
    |> order_by([r], asc: r.date)
    |> first()
    |> Repo.one()
  end

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_records()
      [%Record{}, ...]

  """
  @spec list_records() :: [Record.t()]
  def list_records do
    Repo.all(Record)
  end

  @spec list_records(map, map) :: {:ok, {[Record.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def list_records(params, opts \\ %{}) do
    from(Record, as: :record)
    |> maybe_with_category(opts)
    |> maybe_with_subject(opts)
    |> maybe_with_tags(opts)
    |> Flop.validate_and_run(params, for: Record)
  end

  # @type list_options :: %{
  #         page: integer(),
  #         per_page: integer(),
  #         sort_by: atom(),
  #         sort_order: :asc | :desc,
  #         with_category: boolean(),
  #         with_subject: boolean(),
  #         with_tags: boolean()
  #       }
  #
  # @spec list_records(list_options) :: [Record.t()]
  # def list_records(options) do
  #   from(Record)
  #   |> sort(options)
  #   |> paginate(options)
  #   |> Repo.all()
  #   |> maybe_with_category(options)
  #   |> maybe_with_subject(options)
  #   |> maybe_with_tags(options)
  # end
  #
  # defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
  #   order_by(query, {^sort_order, ^sort_by})
  # end
  #
  # defp sort(query, _options), do: query
  #
  # defp paginate(query, %{page: page, per_page: per_page}) do
  #   offset = max(page - 1, 0) * per_page
  #
  #   query
  #   |> limit(^per_page)
  #   |> offset(^offset)
  # end
  #
  # defp paginate(query, _options), do: query
  #
  def maybe_with_category(record_or_records, %{with_category: true}) do
    record_or_records
    |> join(:left, [record: r], c in assoc(r, :category), as: :category)
    |> preload([category: c], category: c)
  end

  def maybe_with_category(record_or_records, _options), do: record_or_records

  def maybe_with_subject(record_or_records, %{with_subject: true}) do
    record_or_records
    |> join(:left, [record: r], s in assoc(r, :subject), as: :subject)
    |> preload([subject: s], subject: s)
  end

  def maybe_with_subject(record_or_records, _options), do: record_or_records

  def maybe_with_tags(record_or_records, %{with_tags: true}) do
    record_or_records
  end

  def maybe_with_tags(record_or_records, _options), do: record_or_records

  def records_count() do
    Repo.aggregate(Record, :count, :id)
  end

  @doc """
  Gets a single record.

  Raises `Ecto.NoResultsError` if the Record does not exist.

  ## Examples

      iex> get_record!(123)
      %Record{}

      iex> get_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_record!(id, opts \\ %{}) do
    from(Record, as: :record)
    |> where([r], r.id == ^id)
    |> maybe_with_category(opts)
    |> maybe_with_subject(opts)
    |> maybe_with_tags(opts)
    |> Repo.one!()
  end

  def get_record(id, opts \\ %{}) do
    {:ok, get_record!(id, opts)}
  rescue
    Ecto.NoResultsError -> {:error, :not_fund}
  end

  @doc """
  Creates a record.

  ## Examples

      iex> create_record(%{field: value})
      {:ok, %Record{}}

      iex> create_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_record(attrs \\ %{}) do
    %Record{}
    |> record_changeset(attrs)
    |> Repo.insert()
  end

  def create_records(records) do
    Repo.transact(fn ->
      records
      |> Stream.map(&create_record/1)
      |> Enum.find_value(fn
        {:error, reason} -> reason
        _ -> nil
      end)
      |> case do
        nil ->
          :ok

        error_reason ->
          Logger.error("Failed to create records: #{inspect(error_reason)}")
          {:error, error_reason}
      end
    end)
  end

  @doc """
  Updates a record.

  ## Examples

      iex> update_record(record, %{field: new_value})
      {:ok, %Record{}}

      iex> update_record(record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_record(%Record{} = record, attrs) do
    record
    |> record_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a record.

  ## Examples

      iex> delete_record(record)
      {:ok, %Record{}}

      iex> delete_record(record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_record(%Record{} = record) do
    Repo.delete(record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking record changes.

  ## Examples

      iex> change_record(record)
      %Ecto.Changeset{data: %Record{}}

  """
  def change_record(%Record{} = record, attrs \\ %{}) do
    record_changeset(record, attrs)
  end

  @doc false
  defp record_changeset(record, attrs) do
    record
    |> cast(attrs, [:amount, :description, :payment, :tags, :category_id, :subject_id])
    |> cast_datetime_with_timezone(attrs)
    |> Utils.maybe_put_assoc(attrs, key: :subject)
    |> Utils.maybe_put_assoc(attrs, key: :category)
    |> validate_required([:amount, :description, :date, :category_id, :subject_id])
  end

  @spec record_payment_options() :: [{String.t(), atom()}]
  def record_payment_options do
    Ecto.Enum.values(Record, :payment)
    |> Enum.map(&{Record.payment_enum_name(&1), &1})
  end

  def cast_datetime_with_timezone(changeset, attrs)
      when is_map_key(attrs, :date) or is_map_key(attrs, "date") do
    date = attrs[:date] || attrs["date"]
    timezone = attrs[:timezone] || attrs["timezone"] || "Etc/UTC"

    with date when date != nil <- date,
         {:ok, ndate} <- Ecto.Type.cast(:naive_datetime, date),
         {:ok, datetime} <- DateTime.from_naive(ndate, timezone),
         {:ok, datetime} <- DateTime.shift_zone(datetime, "Etc/UTC") do
      changeset |> change(date: datetime)
    else
      nil ->
        changeset

      error ->
        Logger.error("date cast error: #{error}")
        changeset |> add_error(:date, "invalid date: #{date}")
    end
  end

  def cast_datetime_with_timezone(changeset, _), do: changeset
end
