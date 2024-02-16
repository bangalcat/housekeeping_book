defmodule HousekeepingBook.RecordsTest do
  use HousekeepingBook.DataCase

  import HousekeepingBook.AccountsFixtures
  import HousekeepingBook.RecordsFixtures
  import HousekeepingBook.CategoriesFixtures

  alias HousekeepingBook.Records
  alias HousekeepingBook.Schema.Record

  describe "list_records" do
    setup [:setup_records]

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
      valid_attrs = %{
        date: ~U[2023-11-15 05:48:00Z],
        description: "some description",
        amount: 42,
        subject_id: user_fixture().id,
        category_id: category_fixture().id
      }

      assert {:ok, %Record{} = record} = Records.create_record(valid_attrs)
      assert record.date == ~U[2023-11-15 05:48:00Z]
      assert record.description == "some description"
      assert record.amount == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Records.create_record(@invalid_attrs)
    end

    test "update_record/2 with valid data updates the record" do
      user = user_fixture()
      category = category_fixture()
      record = record_fixture(user, category)

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

  describe "get_records_group_by_date/1" do
    test "it should returns records group by date" do
      user = user_fixture()
      category = category_fixture()
      category2 = category_fixture(type: :expense)

      records_map =
        [
          record_fixture(
            %{date: ~U[2023-11-06 05:48:00Z], amount: 10},
            user,
            category
          ),
          record_fixture(
            %{date: ~U[2023-11-15 05:48:00Z], amount: 30},
            user,
            category
          ),
          record_fixture(
            %{date: ~U[2023-11-15 09:48:00Z], amount: 20},
            user,
            category2
          ),
          record_fixture(
            %{date: ~U[2023-11-15 05:48:00Z], amount: 50},
            user,
            category2
          ),
          record_fixture(
            %{date: ~U[2023-11-16 05:48:00Z], amount: 15},
            user,
            category2
          )
        ]
        |> Enum.group_by(
          &{DateTime.to_date(&1.date), &1.category.type},
          & &1.amount
        )
        |> Map.new(fn {key, value} -> {key, Enum.sum(value)} end)

      result =
        HousekeepingBook.Households.get_records_amount_sum_group_by_date_and_type(
          {2023, 11},
          "UTC"
        )

      assert records_map == result
    end
  end

  def setup_records(_) do
    user = user_fixture()
    category = category_fixture()

    records =
      for _ <- 1..10 do
        record_fixture(user, category)
      end

    {:ok, [records: records]}
  end
end
