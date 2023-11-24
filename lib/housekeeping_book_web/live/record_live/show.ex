defmodule HousekeepingBookWeb.RecordLive.Show do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper

  alias HousekeepingBook.Records

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_timezone()}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :record,
       Records.get_record!(id, %{with_category: true, with_subject: true, with_tags: true})
     )}
  end

  def assign_timezone(socket) do
    {timezone, offset} = get_timezone_with_offset(socket)

    socket
    |> assign(:timezone, timezone)
    |> assign(:timezone_offset, offset)
  end

  defp page_title(:show), do: "Show Record"
  defp page_title(:edit), do: "Edit Record"
end
