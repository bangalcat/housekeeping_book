defmodule HousekeepingBookWeb.CategoryLive.Component do
  use Phoenix.Component

  import HousekeepingBookWeb.CoreComponents
  alias HousekeepingBookWeb.CategoryLive.Component.Tree

  attr :tree, Tree, required: true
  attr :last_select, :any
  attr :select_items, :map
  attr :target, :any
  attr :select_item_event, :string, default: "select-item-event"
  attr :select_done_event, :string, default: "select-done-event"

  def columns_tree(assigns) do
    ~H"""
    <div class="flex flex-nowrap max-h-[80vh]">
      <.button
        phx-target={@target}
        phx-click={@select_done_event}
        phx-value-id={@last_select && @last_select.id}
        type="button"
        disabled={is_nil(@last_select)}
        class="my-3 fixed bottom-12 right-12"
      >
        Done
      </.button>
      <div class="flex flex-row flex-nowrap">
        <%= for {selected_id, items, i} <- Tree.pair_list_with_index(@tree) |> dbg do %>
          <.column
            items={items}
            selected={selected_id}
            level={i}
            target={@target}
            select_item_event={@select_item_event}
          />
        <% end %>
      </div>
    </div>
    """
  end

  attr :items, :list, required: true
  attr :selected, :integer
  attr :level, :integer, required: true
  attr :select_item_event, :string, required: true
  attr :target, :any

  def column(assigns) do
    ~H"""
    <ul class="border border-gray-200 rounded overflow-y-auto shadow-md flex-auto">
      <%= for item <- @items do %>
        <li
          id={"item-#{ item.id }"}
          class={"px-4 py-2 cursor-pointer bg-white hover:bg-sky-100 hover:text-sky-900 border-b last:border-none border-gray-200 transition-all duration-300 ease-in-out" <> select_class(@selected == item.id)}
          phx-target={@target}
          phx-click={@select_item_event}
          phx-value-id={item.id}
          phx-value-level={@level}
        >
          <%= item.name %>
        </li>
      <% end %>
    </ul>
    """
  end

  defp select_class(true), do: " bg-sky-200 text-sky-900"
  defp select_class(false), do: ""
end
