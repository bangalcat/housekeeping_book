defmodule HousekeepingBookWeb.CategoryLive.Helper do
  alias HousekeepingBook.Categories

  def parent_name(%{parent: nil}), do: nil

  def parent_name(%{parent: parent}) do
    parent.name
  end

  def new_category do
    Categories.new_category(%{parent: nil})
  end
end
