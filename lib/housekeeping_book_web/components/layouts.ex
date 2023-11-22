defmodule HousekeepingBookWeb.Layouts do
  use HousekeepingBookWeb, :html

  embed_templates "layouts/*"

  slot :menu_item, required: true
  slot :dropdown_item
  slot :top_profile
  slot :inner_block, required: true
  slot :top_button

  def nav(assigns) do
    ~H"""
    <aside class="relative bg-sidebar h-screen w-64 hidden sm:block shadow-xl">
      <div class="p-6">
        <a href="/" class="text-white text-3xl font-semibold uppercase hover:text-gray-300">
          Home
        </a>
        <%= render_slot(@top_button) %>
      </div>
      <nav aria-label="menu nav" class="text-white text-base font-semibold pt-3">
        <ul class="">
          <li
            :for={item <- @menu_item}
            class="items-center active-nav-link text-white py-4 pl-6 nav-item"
          >
            <%= render_slot(item) %>
          </li>
        </ul>
      </nav>
    </aside>

    <div class="w-full flex flex-col h-screen overflow-y-hidden">
      <!-- Desktop Header -->
      <header class="w-full items-center bg-white py-2 px-6 hidden sm:flex">
        <div class="w-1/2"></div>
        <div class="openable relative w-1/2 flex justify-end">
          <%= render_slot(@top_profile) %>
        </div>
      </header>
      <!-- Mobile Header & Nav -->
      <header class="w-full bg-sidebar py-5 px-6 sm:hidden">
        <div class="flex items-center justify-between">
          <a href="/" class="text-white text-3xl font-semibold uppercase hover:text-gray-300">
            Home
          </a>
          <button
            phx-click={JS.toggle(to: ".openable")}
            class="text-white text-3xl focus:outline-none"
          >
            <.icon name="hero-bars-3" class="openable flex" />
            <.icon name="hero-x-mark" class="openable hidden" />
          </button>
        </div>
        <!-- Dropdown Nav -->
        <.dropdown_nav>
          <:dropdown_item :for={item <- @menu_item}>
            <%= render_slot(item) %>
          </:dropdown_item>
          <:dropdown_item :for={item <- @dropdown_item}>
            <%= render_slot(item) %>
          </:dropdown_item>
        </.dropdown_nav>
      </header>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot :dropdown_item, required: true

  defp dropdown_nav(assigns) do
    ~H"""
    <nav id="dropdown-nav" class="openable hidden flex-col pt-4" phx-mounted={JS.hide()}>
      <ul>
        <li
          :for={item <- @dropdown_item}
          class="flex items-center text-white opacity-75 hover:opacity-100 py-2 pl-4 nav-item"
        >
          <%= render_slot(item) %>
        </li>
      </ul>
      <button class="w-full bg-white cta-btn font-semibold py-2 mt-3 rounded-lg shadow-lg hover:shadow-xl hover:bg-gray-300 flex items-center justify-center">
        <i class="fas fa-arrow-circle-up mr-3"></i> Upgrade to Pro!
      </button>
    </nav>
    """
  end
end
