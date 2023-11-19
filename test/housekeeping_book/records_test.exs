defmodule HousekeepingBook.RecordsTest do
  use HousekeepingBook.DataCase

  alias HousekeepingBook.Records
  alias HousekeepingBook.Schema.Record

  @moduletag :current

  describe "list_records" do
    setup [:setup_records]

    test "list_records/0 returns all records", %{records: records} do
      result_records = Records.list_records() |> Enum.sort_by(& &1.id)

      for {expect, result} <- Enum.zip(records, result_records) do
        assert_same_schema(expect, result)
      end
    end

    test "list_records/1 with pagination options returns paginated records ", %{
      records: expect_records
    } do
      options = %{page: 1, per_page: 5}
      {:ok, {result_records, _meta}} = Records.list_records(options)

      for {expect, result} <- expect_records |> Enum.take(5) |> Enum.zip(result_records) do
        assert_same_schema(expect, result)
      end
    end
  end

  describe "records" do
    @invalid_attrs %{date: nil, description: nil, amount: nil}

    test "get_record!/1 returns the record with given id" do
      record = insert!(:record)
      assert_same_schema(Records.get_record!(record.id), record)
    end

    test "create_record/1 with valid data creates a record" do
      valid_attrs = %{date: ~U[2023-11-15 05:48:00Z], description: "some description", amount: 42}

      assert {:ok, %Record{} = record} = Records.create_record(valid_attrs)
      assert record.date == ~U[2023-11-15 05:48:00Z]
      assert record.description == "some description"
      assert record.amount == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_record(@invalid_attrs)
    end

    test "update_record/2 with valid data updates the record" do
      record = insert!(:record)

      update_attrs = %{
        date: ~U[2023-11-16 05:48:00Z],
        description: "some updated description",
        amount: 43
      }

      assert {:ok, %Record{} = record} = Records.update_record(record, update_attrs)
      assert record.date == ~U[2023-11-16 05:48:00Z]
      assert record.description == "some updated description"
      assert record.amount == 43
    end

    test "update_record/2 with invalid data returns error changeset" do
      record = insert!(:record)
      assert {:error, %Ecto.Changeset{}} = Records.update_record(record, @invalid_attrs)
      assert record == Records.get_record!(record.id)
    end

    test "delete_record/1 deletes the record" do
      record = insert!(:record)
      assert {:ok, %Record{}} = Records.delete_record(record)
      assert_raise Ecto.NoResultsError, fn -> Records.get_record!(record.id) end
    end

    test "change_record/1 returns a record changeset" do
      record = insert!(:record)
      assert %Ecto.Changeset{} = Records.change_record(record)
    end
  end

  def setup_records(_) do
    records =
      for _ <- 1..10 do
        insert!(:record, %{})
      end

    {:ok, [records: records]}
  end
end
