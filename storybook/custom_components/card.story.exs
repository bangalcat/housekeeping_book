defmodule Storybook.CustomComponents.Card do
  use PhoenixStorybook.Story, :component

  def function, do: &HousekeepingBookWeb.CustomComponents.card/1

  def template do
    """
    <div class="lsb-w-full lsb-grid gap-4">
      <.lsb-variation-group/>
    </div>
    """
  end

  def variations do
    [
      %VariationGroup{
        id: :basic,
        variations:
          for i <- 1..5 do
            %Variation{
              id: :"var-#{i}",
              attributes: %{},
              slots: [
                """
                <:card_header>
                  <div class="lsb-text-gray-500">
                    2023/01/01
                  </div>
                </:card_header>
                """,
                """
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
                """
              ]
            }
          end
      },
      %Variation{
        id: :custom_class,
        attributes: %{},
        slots: [
          """
          <:card_header>
            Card title
          </:card_header>
          """,
          """
          <:card_body>
            Card body
          </:card_body>
          <:card_footer>
            footer
          </:card_footer>
          """
        ]
      }
    ]
  end
end
