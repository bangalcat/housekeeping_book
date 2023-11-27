defmodule HousekeepingBook.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HousekeepingBook.Categories` context.
  """

  def unique_name, do: "category-#{System.unique_integer()}"

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: unique_name(),
        type: :income
      })
      |> HousekeepingBook.Categories.create_category()

    category
  end
end
