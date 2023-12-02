defmodule HousekeepingBookWeb.RecordLive.FormComponent do
  use HousekeepingBookWeb, :live_component

  alias HousekeepingBook.Records
  alias HousekeepingBookWeb.CategoryLive.Component.Tree

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="record-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        phx-debounce={120}
      >
        <.input field={@form[:date]} type="datetime-local" label="Date" timezone={@timezone} />
        <.input type="hidden" id="timezone" field={@form[:timezone]} value={@timezone} />
        <.input
          type="hidden"
          id="timezone-offset"
          field={@form[:timezone_offset]}
          value={@timezone_offset}
        />
        <.input field={@form[:amount]} type="number" label="Amount" />
        <.input field={@form[:description]} type="text" label="Description" />
        <div phx-feedback-for="category">
          <.label>
            Category
          </.label>
          <.button
            type="button"
            phx-click="toggle-tree-modal"
            phx-target={@myself}
            class="py-1 rounded-sm bg-primary-600 hover:bg-primary-400"
          >
            <%= if @last_select_category do %>
              <%= @last_select_category.name %>
            <% else %>
              Select Category
            <% end %>
          </.button>
          <.error :for={error <- @form[:category_id].errors}><%= translate_error(error) %></.error>
        </div>
        <.input
          field={@form[:subject_id]}
          type="select"
          label="Subject"
          options={@options[:subject]}
          prompt="Choose a user"
        />
        <.input
          field={@form[:payment]}
          type="select"
          label="Payment"
          options={@options[:payment]}
          prompt="Choose a payment type"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Record</.button>
        </:actions>
      </.simple_form>
      <.modal
        :if={@open_tree_modal}
        id="category-tree-modal"
        show
        on_cancel={JS.push("toggle-tree-modal", target: @myself)}
      >
        <HousekeepingBookWeb.CategoryLive.Component.columns_tree
          tree={@tree}
          last_select={@last_select_category}
          target={@myself}
          select_item_event="tree-select-item"
          select_done_event="tree-select-done"
        />
      </.modal>
    </div>
    """
  end

  @impl true
  def update(%{record: record} = assigns, socket) do
    changeset = Records.change_record(record)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(tree: Tree.new(), open_tree_modal: false, last_select_category: record.category)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"record" => record_params}, socket) do
    changeset =
      socket.assigns.record
      |> Records.change_record(record_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"record" => record_params}, socket) do
    record_params =
      record_params
      |> Map.put(
        "category_id",
        socket.assigns.last_select_category && socket.assigns.last_select_category.id
      )

    save_record(socket, socket.assigns.action, record_params)
  end

  def handle_event("toggle-tree-modal", _, socket) do
    socket =
      case socket.assigns.open_tree_modal do
        false ->
          top_categories = HousekeepingBook.Categories.top_categories()

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

  def handle_event("tree-select-done", %{"id" => _id}, socket) do
    {:noreply, socket |> assign(:open_tree_modal, false)}
  end

  defp handle_select_item(socket, id, level) do
    items = HousekeepingBook.Categories.child_categories(id)

    tree =
      socket.assigns.tree
      |> Tree.drop_columns_below(level)
      |> Tree.add_column(items, id)

    socket
    |> assign(:tree, tree)
    |> assign(:last_select_category, Tree.last_select_item(tree))
  end

  defp save_record(socket, :edit, record_params) do
    case Records.update_record(socket.assigns.record, record_params) do
      {:ok, record} ->
        notify_parent({:saved, record})

        {:noreply,
         socket
         |> put_flash(:info, "Record updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_record(socket, :new, record_params) do
    case Records.create_record(record_params) do
      {:ok, record} ->
        notify_parent({:saved, record})

        {:noreply,
         socket
         |> put_flash(:info, "Record created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
