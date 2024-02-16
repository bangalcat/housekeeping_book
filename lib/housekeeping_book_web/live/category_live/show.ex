defmodule HousekeepingBookWeb.CategoryLive.Show do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.CategoryLive.Helper

  alias HousekeepingBook.Households

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, Households.Category.get_by_id!(id, load: [:parent]))}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
end
