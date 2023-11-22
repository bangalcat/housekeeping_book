defmodule HousekeepingBookWeb.RecordLive.Index do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper
  require Logger

  alias HousekeepingBook.Records

  @impl true
  def mount(_params, session, socket) do
    # socket = assign_user_device(socket, session)
    {:ok, socket |> assign(records: nil, meta: nil) |> assign_options()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # socket = socket |> assign_list_records(params)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Record")
    |> assign(
      :record,
      Records.get_record!(id, %{with_category: true, with_subject: true, with_tags: true})
    )
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
        |> assign(%{records: records, meta: meta})

      {:error, meta} ->
        socket
        |> assign(:meta, meta)
    end
  end

  defp assign_options(socket) do
    socket
    |> assign(:options, record_options())
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

    {:noreply, push_patch(socket, to: ~p"/records")}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, _record}}, socket) do
    {:noreply, push_patch(socket, to: ~p"/records")}
  end
end
