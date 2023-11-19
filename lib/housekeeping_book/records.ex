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

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_records()
      [%Record{}, ...]

  """
  def list_records do
    Repo.all(Record)
  end

  @spec list_records(map, map) :: {:ok, {[Record.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def list_records(params, opts \\ %{}) do
    Record
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
  def maybe_with_category(records, %{with_category: true}) do
    records
    |> join(:left, [r], c in assoc(r, :category), as: :category)
    |> preload([category: c], category: c)
  end

  def maybe_with_category(records, _options), do: records

  def maybe_with_subject(records, %{with_subject: true}) do
    records
    |> join(:left, [r], s in assoc(r, :subject), as: :subject)
    |> preload([subject: s], subject: s)
  end

  def maybe_with_subject(records, _options), do: records

  def maybe_with_tags(records, %{with_tags: true}) do
    records
  end

  def maybe_with_tags(records, _options), do: records

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
  def get_record!(id), do: Repo.get!(Record, id)

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
    |> cast(attrs, [:amount, :description, :date, :payment, :tags])
    |> Utils.maybe_put_assoc(attrs, key: :subject)
    |> Utils.maybe_put_assoc(attrs, key: :category)
    |> validate_required([:amount, :description, :date])
  end
end
