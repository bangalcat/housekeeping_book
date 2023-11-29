defmodule HousekeepingBook.CategoriesTest do
  use HousekeepingBook.DataCase

  import HousekeepingBook.TestUtils

  alias HousekeepingBook.Categories

  alias HousekeepingBook.Schema.Category

  @moduletag :current

  describe "categories" do
    @invalid_attrs %{name: nil, type: nil}

    test "list_categories/0 returns all categories" do
      category = insert!(:category)
      [res_cat] = Categories.list_categories()
      assert_same_schema(category, res_cat)
    end

    test "list_categories/0 returns all categories with parent preload" do
      cat = insert!(:category) |> Repo.preload(:parent)
      [res_cat] = Categories.list_categories()
      assert_same_fields(cat, res_cat)
    end

    test "get_category!/1 returns the category with given id and parent preloaded" do
      category = insert!(:category) |> Repo.preload(:parent)
      assert Categories.get_category!(category.id) == category
    end

    test "delete_category/1 deletes the category" do
      category = insert!(:category)
      assert {:ok, %Category{}} = Categories.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
    end

    test "bottom_categories/0 should returns only categories without children" do
      top_category = insert!(:category)
      parent_category = insert!(:category, %{parent_id: top_category.id})
      leaf_category = insert!(:category, %{parent_id: parent_category.id})

      assert_same_schema([leaf_category], Categories.bottom_categories())
    end

    test "top_categories/0 should returns only categories without parent" do
      top_category = insert!(:category)
      parent_category = insert!(:category, %{parent_id: top_category.id})
      _leaf_category = insert!(:category, %{parent_id: parent_category.id})

      assert_same_schema([top_category], Categories.top_categories())
    end

    test "child_categories/1 should returns only children categories with given parent" do
      top_category = insert!(:category)
      cat_1 = insert!(:category, %{parent_id: top_category.id})
      cat_2 = insert!(:category, %{parent_id: top_category.id})
      assert_same_schema([cat_1, cat_2], Categories.child_categories(top_category))
      assert_same_schema([cat_1, cat_2], Categories.child_categories(top_category.id))
    end
  end

  describe "create and update categories" do
    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", type: :income}

      assert {:ok, %Category{} = category} = Categories.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.type == :income
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = insert!(:category)
      update_attrs = %{name: "some updated name", type: :expense}

      assert {:ok, %Category{} = category} = Categories.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.type == :expense
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = insert!(:category) |> Repo.preload(:parent)
      assert {:error, %Ecto.Changeset{}} = Categories.update_category(category, @invalid_attrs)
      assert category == Categories.get_category!(category.id)
    end

    test "change_category/1 returns a category changeset" do
      category = insert!(:category)
      assert %Ecto.Changeset{} = Categories.change_category(category)
    end

    test "it should have the same type as it's parent category" do
      %{id: cat_id} = cat = insert!(:category, %{type: :income})
      %{id: cat2_id} = cat2 = insert!(:category, %{type: :expense})
      new_attrs = %{name: "test", parent: cat}

      assert {:ok, %{parent_id: ^cat_id, type: :income} = child_cat} =
               Categories.create_category(new_attrs)

      assert %Ecto.Changeset{changes: %{type: :expense, parent_id: ^cat2_id}} =
               Categories.change_category(child_cat, %{parent: cat2})

      assert {:ok, %{parent_id: ^cat2_id, type: :expense}} =
               Categories.update_category(child_cat, %{parent: cat2})
    end

    test "it could not have itself as parent" do
      {:ok, cat} = Categories.create_category(%{name: "cat"})
      assert %Ecto.Changeset{valid?: false} = Categories.change_category(cat, %{parent: cat})
    end

    test "it should pass the parent in attrs instead of parent_id" do
      {:ok, cat} = Categories.create_category(%{name: "cat", type: :income})

      assert {:error, %Ecto.Changeset{} = changeset} =
               Categories.create_category(%{name: "bat", parent_id: cat.id})

      assert %{parent: [msg]} = errors_on(changeset)
      assert msg =~ "should be set parent"
    end
  end

  describe "leaf_category?" do
    test "it should return true or false" do
      %{id: cat_id} = cat = insert!(:category, %{type: :income})
      cat2 = insert!(:category, %{type: :expense, parent_id: cat_id})

      assert Categories.leaf_category?(cat2)
      refute Categories.leaf_category?(cat)
    end
  end
end
