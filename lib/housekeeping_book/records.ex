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
