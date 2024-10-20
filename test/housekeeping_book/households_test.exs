defmodule HousekeepingBook.HouseholdsTest do
  use HousekeepingBook.DataCase

  import HousekeepingBook.AccountsFixtures
  import HousekeepingBook.RecordsFixtures
  import HousekeepingBook.CategoriesFixtures
  import HousekeepingBook.TagsFixtures

  alias HousekeepingBook.Households

  describe "records" do
    @invalid_attrs %{date: nil, description: nil, amount: nil}

    test "create_record/1 with valid data creates a record" do
      valid_attrs = %{
        date: ~U[2023-11-15 05:48:00Z],
        description: "some description",
        amount: 42,
        subject_id: user_fixture().id,
        category_id: category_fixture().id
      }

      assert {:ok, %Households.Record{} = record} = Households.create_record(valid_attrs)
      assert record.date == ~U[2023-11-15 05:48:00Z]
      assert record.description == "some description"
      assert record.amount == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Changes.Required{}, %{}, %{}]}} =
               Households.create_record(@invalid_attrs)
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

      assert {:ok, %Households.Record{} = record} = Households.update_record(record, update_attrs)
      assert record.date == ~U[2023-11-16 05:48:00Z]
      assert record.description == "some updated description"
      assert record.amount == 43
    end

    test "update_record/2 with invalid data returns error changeset" do
      user = user_fixture()
      category = category_fixture()
      record = record_fixture(user, category)

      assert {:error,
              %Ash.Error.Invalid{
                changeset: %Ash.Changeset{},
                errors: [%_{field: :date, type: :attribute}]
              }} =
               Households.update_record(record, @invalid_attrs)

      assert Map.take(record, Map.keys(@invalid_attrs)) ==
               Ash.get!(Households.Record, record.id, load: [:category, :subject])
               |> Map.take(Map.keys(@invalid_attrs))
    end

    test "delete_record/1 deletes the record" do
      user = user_fixture()
      category = category_fixture()
      record = record_fixture(user, category)
      assert :ok = Households.delete_record(record)
      assert_raise Ash.Error.Query.NotFound, fn -> Households.get_record!(record.id) end
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
        Households.get_records_amount_sum_group_by_date_and_type(
          {2023, 11},
          "UTC"
        )

      assert records_map == result
    end
  end

  describe "categories" do
    @invalid_attrs %{name: nil, type: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      {:ok, [res_cat]} = Households.list_categories()
      assert_same_schema(category, res_cat)
    end

    test "list_categories/0 returns all categories with parent preload" do
      cat = category_fixture()
      {:ok, [res_cat]} = Households.list_categories()
      assert_same_fields(cat, res_cat)
    end

    test "get_category!/1 returns the category with given id and parent preloaded" do
      category = category_fixture()
      assert_same_fields(Households.get_category!(category.id), category)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert :ok = Households.delete_category(category)
      assert_raise Ash.Error.Invalid, fn -> Households.get_category!(category.id) end
    end

    test "bottom_categories/0 should returns only categories without children" do
      top_category = category_fixture()
      parent_category = category_fixture(%{parent_id: top_category.id})
      leaf_category = category_fixture(%{parent_id: parent_category.id})

      assert {:ok, bottom_categories} = Households.bottom_categories()
      assert_same_schema([leaf_category], bottom_categories)
    end

    test "top_categories/0 should returns only categories without parent" do
      top_category = category_fixture()

      parent_category = category_fixture(%{parent_id: top_category.id})
      _leaf_category = category_fixture(%{parent_id: parent_category.id})

      assert_same_schema([top_category], Households.top_categories!())
    end

    test "child_categories/1 should returns only children categories with given parent" do
      top_category = category_fixture()

      cat_1 = category_fixture(%{parent_id: top_category.id})
      cat_2 = category_fixture(%{parent_id: top_category.id})
      assert_same_schema([cat_1, cat_2], Households.child_categories!(top_category.id))
      assert_same_schema([cat_1, cat_2], Households.child_categories!(top_category.id))
    end
  end

  describe "create and update categories" do
    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", type: :income}

      assert {:ok, %Households.Category{} = category} = Households.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.type == :income
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Households.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", type: :expense}

      assert {:ok, %Households.Category{} = category} =
               Households.update_category(category, update_attrs)

      assert category.name == "some updated name"
      assert category.type == :expense
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ash.Error.Invalid{}} = Households.update_category(category, @invalid_attrs)
      assert_same_schema(category, Households.get_category!(category.id))
    end

    test "it should have the same type as it's parent category" do
      %{id: cat_id} = cat = category_fixture(%{type: :income})
      %{id: cat2_id} = cat2 = category_fixture(%{type: :expense})
      new_attrs = %{name: "test", parent_id: cat.id}

      assert {:ok, %{parent_id: ^cat_id, type: :expense} = child_cat} =
               Households.create_category(new_attrs)

      assert {:ok, %{parent_id: ^cat2_id, type: :expense}} =
               Households.update_category(child_cat, %{parent_id: cat2.id})
    end

    test "it could not have itself as parent" do
      {:ok, cat} = Households.create_category(%{name: "cat"})

      assert {:error, %Ash.Error.Invalid{errors: [%{field: :parent_id}]}} =
               Households.update_category(cat, %{parent_id: cat.id})
    end
  end

  describe "leaf_category?" do
    test "it should return true or false" do
      %{id: cat_id} = cat = category_fixture(%{type: :income})
      cat2 = category_fixture(%{type: :expense, parent_id: cat_id})

      assert Households.leaf_category?(cat2)
      refute Households.leaf_category?(cat)
    end
  end

  describe "tags" do
    test "list_tags" do
      assert {:ok, []} = Households.list_tags()
      tag = tag_fixture()
      assert {:ok, [res_tag]} = Households.list_tags()
      assert_same_schema(tag, res_tag)
    end

    test "create_tag" do
      assert {:ok, %Households.Tag{}} = Households.create_tag(%{name: "Test"})
    end

    test "update_tag" do
      assert {:ok, tag} = Households.create_tag(%{name: "Test"})
      assert {:ok, %Households.Tag{name: "Tests"}} = Households.update_tag(tag, %{name: "Tests"})
    end

    test "delete_tag" do
      assert {:ok, tag} = Households.create_tag(%{name: "Test"})
      assert :ok = Households.delete_tag(tag)
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
