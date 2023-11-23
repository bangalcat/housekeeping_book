defmodule Storybook.Examples.My.ResponsiveNav do
  use PhoenixStorybook.Story, :example

  import HousekeepingBookWeb.Layouts
  import HousekeepingBookWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex bg-gray-100 h-[calc(100dvh)]">
      <.nav_layout>
        <:top_button>
          <p>
            <.icon name="hero-home" /> Home
          </p>
        </:top_button>
        <:menu_item>
          <.link>Blog</.link>
        </:menu_item>
        <:menu_item>
          <.link>Site</.link>
        </:menu_item>
        <:menu_item>
          <.link>About</.link>
        </:menu_item>
      </.nav_layout>
    </div>
    """
  end
end
