defmodule HousekeepingBookWeb.RecordLive.Show do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_timezone()}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    return_to = params["return_to"] || ~p"/records"

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:return_to, return_to)
     |> assign(
       :record,
       Ash.get!(HousekeepingBook.Households.Record, id, load: [:category, :subject, :tags])
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
