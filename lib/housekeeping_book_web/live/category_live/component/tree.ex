defmodule HousekeepingBookWeb.CategoryLive.Component.Tree do
  @type t :: %__MODULE__{}

  defstruct columns: [], selected_ids: []

  def new do
    %__MODULE__{}
  end

  def add_column(tree, items, parent_id) when is_list(items) do
    tree
    |> Map.put(:columns, tree.columns ++ [items])
    |> Map.put(:selected_ids, [parent_id] ++ tree.selected_ids)
  end

  def drop_columns_below(tree, level) when level >= 0 do
    tree
    |> Map.put(:columns, Enum.take(tree.columns, level + 1))
    |> Map.put(:selected_ids, Enum.take(tree.selected_ids, -level - 1))
  end

  def last_select_item(%__MODULE__{selected_ids: [nil]}), do: nil

  def last_select_item(tree) do
    last_id = tree.selected_ids |> hd()
    tree.columns |> Enum.at(-2) |> Enum.find(&(&1.id == last_id))
  end

  def pair_list_with_index(%__MODULE__{} = tree) do
    [nil | tree.selected_ids]
    |> Enum.reverse()
    |> tl()
    |> Enum.zip(tree.columns)
    |> Enum.with_index(fn {selected_id, items}, index ->
      {selected_id, items, index}
    end)
  end
end
