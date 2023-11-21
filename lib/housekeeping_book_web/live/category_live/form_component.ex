defmodule HousekeepingBookWeb.CategoryLive.FormComponent do
  use HousekeepingBookWeb, :live_component

  import HousekeepingBookWeb.CategoryLive.Helper
  import HousekeepingBookWeb.CategoryLive.Component
  alias HousekeepingBookWeb.CategoryLive.Component.Tree
  alias HousekeepingBook.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:type]} type="select" label="Type" options={category_type_options()} />
        <div phx-feedback-for="parent">
          Parent Category:
          <input
            id="parent-category-name"
            type="text"
            name="parent"
            disabled
            value={if @last_select, do: @last_select.name, else: "None"}
          />
          <.error :for={msg <- @form[:parent].errors}><%= msg %></.error>
          <.button type="button" phx-click="toggle-tree-modal" phx-target={@myself}>
            Select Parent Category
          </.button>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Category</.button>
        </:actions>
      </.simple_form>

      <.modal
        :if={@open_tree_modal}
        id="category-tree-modal"
        show
        on_cancel={JS.push("toggle-tree-modal", target: @myself)}
      >
        <.columns_tree
          tree={@tree}
          last_select={@last_select}
          target={@myself}
          select_item_event="tree-select-item"
          select_done_event="tree-select-done"
        />
      </.modal>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Categories.change_category(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(tree: Tree.new(), open_tree_modal: false, last_select: category.parent)
     # |> assign_new(:options, fn -> category_options() end)
     |> assign_form(changeset)}
  end

  def update(%{parent_select: parent} = _assigns, socket) do
    changeset =
      Categories.change_category(socket.assigns.category, %{parent_id: parent.id, parent: parent})

    {:ok, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    category_params = category_params |> Map.put("parent", socket.assigns.last_select)

    changeset =
      socket.assigns.category
      |> Categories.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    category_params = category_params |> Map.put("parent", socket.assigns.last_select) |> dbg()
    save_category(socket, socket.assigns.action, category_params)
  end

  def handle_event("toggle-tree-modal", _, socket) do
    socket =
      case socket.assigns.open_tree_modal do
        false ->
          top_categories = Categories.top_categories()

          socket
          |> assign(:tree, Tree.add_column(Tree.new(), top_categories, nil))
          |> assign(:open_tree_modal, true)

        true ->
          socket
          |> assign(:open_tree_modal, false)
      end

    {:noreply, socket}
  end

  def handle_event("tree-select-item", %{"id" => id, "level" => level}, socket) do
    socket = handle_select_item(socket, String.to_integer(id), String.to_integer(level))
    {:noreply, socket}
  end

  def handle_event("tree-select-done", _, socket) do
    {:noreply, socket |> assign(:open_tree_modal, false)}
  end

  defp save_category(socket, :edit, category_params) do
    case Categories.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Categories.create_category(category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp handle_select_item(socket, id, level) do
    items = Categories.child_categories(id)

    tree =
      socket.assigns.tree
      |> Tree.drop_columns_below(level)
      |> Tree.add_column(items, id)

    socket
    |> assign(:tree, tree)
    |> assign(:last_select, Tree.last_select_item(tree))
  end
end
