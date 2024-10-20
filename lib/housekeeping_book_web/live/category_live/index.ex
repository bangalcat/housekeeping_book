defmodule HousekeepingBookWeb.CategoryLive.Index do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.CategoryLive.Helper

  alias HousekeepingBook.Households

  @impl true
  def mount(_params, _session, socket) do
    categories = Households.Category.read!(load: [:parent])
    {:ok, stream(socket, :categories, categories)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Households.get_category!(id, load: [:parent]))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, new_category())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({HousekeepingBookWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    category = Ash.load!(category, [:parent])
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Households.get_category!(id)
    Households.Category.delete!(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
