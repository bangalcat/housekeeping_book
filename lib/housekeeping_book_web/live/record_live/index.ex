defmodule HousekeepingBookWeb.RecordLive.Index do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper
  require Logger

  alias HousekeepingBook.Records

  @impl true
  def mount(_params, session, socket) do
    socket = assign_user_device(socket, session)

    {:ok,
     socket
     |> assign_timezone()
     |> assign(:meta, nil)
     |> stream(:records, [])
     |> assign_options()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # socket = socket |> assign_list_records(params)
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
    case Records.list_records(params, %{
           with_category: true,
           with_subject: true,
           with_tags: true
         }) do
      {:ok, {records, meta}} ->
        socket
        |> assign(%{meta: meta})
        |> stream(:records, records, reset: true)

      {:error, meta} ->
        socket
        |> assign(:meta, meta)
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
    record = Records.get_record!(id)
    {:ok, _} = Records.delete_record(record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, record}}, socket) do
    record = get_record!(record.id)
    {:noreply, stream_insert(socket, :records, record)}
  end
end
