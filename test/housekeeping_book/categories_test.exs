defmodule HousekeepingBook.CategoriesTest do
  use HousekeepingBook.DataCase

  alias HousekeepingBook.Categories

  alias HousekeepingBook.Schema.Category

  @moduletag :current

  describe "categories" do
    @invalid_attrs %{name: nil, type: nil}

    test "list_categories/0 returns all categories" do
      category = insert!(:category)
      assert Categories.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = insert!(:category)
      assert Categories.get_category!(category.id) == category
    end

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
      category = insert!(:category)
      assert {:error, %Ecto.Changeset{}} = Categories.update_category(category, @invalid_attrs)
      assert category == Categories.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = insert!(:category)
      assert {:ok, %Category{}} = Categories.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = insert!(:category)
      assert %Ecto.Changeset{} = Categories.change_category(category)
    end
  end
end
