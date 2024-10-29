defmodule HousekeepingBookWeb.CategoryLive.Helper do
  def parent_name(%{parent: nil}), do: nil

  def parent_name(%{parent: parent}) do
    parent.name
  end

  def new_category do
    %HousekeepingBook.Households.Category{parent: nil}
  end

  def category_type_options do
    HousekeepingBook.Households.category_type_options()
  end
end
