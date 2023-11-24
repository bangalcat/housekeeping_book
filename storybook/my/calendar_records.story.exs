defmodule Storybook.Examples.My.ResponsiveNav do
  use PhoenixStorybook.Story, :example

  alias HousekeepingBookWeb.CustomComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col max-w-lg lsb">
      <CustomComponents.calendar
        current_year={2023}
        current_month={11}
        selected_date={~U[2023-11-24 00:00:00Z]}
        day_content_fn={&__MODULE__.day_content/1}
      />
      <div class="space-y-3 pt-4 lsb-bg-gray-200 lsb-px-4">
        <CustomComponents.card :for={_i <- 1..10} class="bg-sky-100">
          <:card_header>
            <div class="lsb-text-gray-500">
              2023/01/01
            </div>
          </:card_header>
          <:card_body>
            <span class="lsb-grow">
              돼지고기 두근
            </span>
            <span class="lsb-flex-none">-3,000원</span>
          </:card_body>
          <:card_footer>
            <span>식비</span>
            <span>방갈</span>
          </:card_footer>
        </CustomComponents.card>
      </div>
    </div>
    """
  end

  def day_content({_, _, day}) when rem(day, 6) == 0 do
    CustomComponents.my_day_content(%{income: "1,000", expense: "4,000"})
  end

  def day_content(_) do
    ""
  end
end
