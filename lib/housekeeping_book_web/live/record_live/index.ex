defmodule HousekeepingBookWeb.RecordLive.Index do
  use HousekeepingBookWeb, :live_view
  require Logger

  alias HousekeepingBook.Records
  alias HousekeepingBook.Schema.Record

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Record")
    |> assign(:record, Records.get_record!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Record")
    |> assign(:record, %Record{})
  end

  defp apply_action(socket, :index, params) do
    case Records.list_records(params, %{with_category: true, with_subject: true, with_tags: true}) do
      {:ok, {records, meta}} ->
        socket
        |> assign(:page_title, "Listing Records")
        |> assign(:record, nil)
        |> assign(%{records: records, meta: meta})

      {:error, meta} ->
        Logger.debug(inspect(meta))
        socket
    end
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/records?#{params}")}
  end

  @impl true
  def handle_event("select-per-page", %{"page-size" => per_page} = _params, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    socket = push_patch(socket, to: ~p"/records?#{params}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    record = Records.get_record!(id)
    {:ok, _} = Records.delete_record(record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, record}}, socket) do
    {:noreply, stream_insert(socket, :records, record)}
  end
end
