defmodule HousekeepingBookWeb.RecordLive.Index do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper
  require Logger

  alias HousekeepingBook.Households

  @impl true
  def mount(_params, session, socket) do
    socket = assign_user_device(socket, session)

    filter_form = AshPhoenix.FilterForm.new(Households.Record)

    {:ok,
     socket
     |> assign_timezone()
     |> assign(filter_form: filter_form)
     |> stream(:records, [])
     |> assign_options()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Record")
    |> assign(:record, get_record!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Record")
    |> assign(:record, new_record())
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign_list_records(params)
    |> assign(:page_title, "Listing Records")
    |> assign(:record, nil)
  end

  def assign_list_records(socket, params) do
    filter_form =
      socket.assigns.filter_form
      |> AshPhoenix.FilterForm.validate(params)

    with {:ok, filter} <- AshPhoenix.FilterForm.filter(Households.Record, filter_form),
         {:ok, %Ash.Page.Keyset{results: records}} <-
           Households.Record.read_all(query: filter, load: [:subject, :category, :tags]) do
      socket
      |> stream(:records, records, reset: true)
    else
      {:error, %AshPhoenix.FilterForm{} = filter} ->
        socket
        |> assign(:filter_form, filter)

      {:error, error} ->
        Logger.error("Error: #{inspect(error)}")
        socket
    end
  end

  defp assign_options(socket) do
    socket
    |> assign(:options, record_options())
  end

  def assign_timezone(socket) do
    {timezone, offset} = get_timezone_with_offset(socket)

    socket
    |> assign(:timezone, timezone)
    |> assign(:timezone_offset, offset)
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/records?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    record = get_record!(id)
    delete_record!(record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  def handle_event("filter-validate", %{"filter" => params}, socket) do
    {:noreply,
     assign(socket,
       filter_form: AshPhoenix.FilterForm.validate(socket.assigns.filter_form, params)
     )}
  end

  def handle_event("filter-submit", %{"filter" => params}, socket) do
    {:noreply, assign_list_records(socket, params)}
  end

  def handle_event("remove_filter_component", %{"component-id" => component_id}, socket) do
    {:noreply,
     assign(socket,
       filter_form:
         AshPhoenix.FilterForm.remove_component(socket.assigns.filter_form, component_id)
     )}
  end

  def handle_event("add_filter_group", %{"component-id" => component_id}, socket) do
    {:noreply,
     assign(socket,
       filter_form: AshPhoenix.FilterForm.add_group(socket.assigns.filter_form, to: component_id)
     )}
  end

  def handle_event("add_filter_predicate", %{"component-id" => component_id}, socket) do
    {:noreply,
     assign(socket,
       filter_form:
         AshPhoenix.FilterForm.add_predicate(socket.assigns.filter_form, :name, :contains, nil,
           to: component_id
         )
     )}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, record}}, socket) do
    record = get_record!(record.id)
    {:noreply, stream_insert(socket, :records, record)}
  end

  def filter_form_component(%{component: %{source: %AshPhoenix.FilterForm{}}} = assigns) do
    ~H"""
    <div class="border-gray-50 border-8 p-4 rounded-xl mt-4">
      <div class="flex flex-row justify-between">
        <div class="flex flex-row gap-2 items-center">Filter</div>
        <div class="flex flex-row gap-2 items-center">
          <.input type="select" field={@component[:operator]} options={["and", "or"]} />
          <.button
            phx-click="add_filter_group"
            phx-value-component-id={@component.source.id}
            type="button"
          >
            Add Group
          </.button>
          <.button
            phx-click="add_filter_predicate"
            phx-value-component-id={@component.source.id}
            type="button"
          >
            Add Predicate
          </.button>
          <.button
            phx-click="remove_filter_component"
            phx-value-component-id={@component.source.id}
            type="button"
          >
            Remove Group
          </.button>
        </div>
      </div>
      <.inputs_for :let={component} field={@component[:components]}>
        <.filter_form_component component={component} />
      </.inputs_for>
    </div>
    """
  end

  def filter_form_component(%{component: %{source: %AshPhoenix.FilterForm.Predicate{}}} = assigns) do
    ~H"""
    <div class="flex flex-row gap-2 mt-4">
      <.input
        type="select"
        options={AshPhoenix.FilterForm.fields(Households.Record)}
        field={@component[:field]}
      />
      <.input
        type="select"
        options={AshPhoenix.FilterForm.predicates(Households.Record)}
        field={@component[:operator]}
      />
      <.input field={@component[:value]} />
      <.button
        phx-click="remove_filter_component"
        phx-value-component-id={@component.source.id}
        type="button"
      >
        Remove
      </.button>
    </div>
    """
  end
end
