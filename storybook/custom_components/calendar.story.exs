defmodule Storybook.CustomComponents.Calendar do
  use PhoenixStorybook.Story, :component

  def function, do: &HousekeepingBookWeb.CustomComponents.calendar/1

  def template_fixed_width do
    """
    <div class="w-80">
      <.lsb-variation-group/>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :basic,
        attributes: %{
          current_year: 2023,
          current_month: 11,
          selected_date: ~U[2023-11-24 00:00:00Z],
          day_content_fn: &__MODULE__.day_content/1
        },
        slots: [
          """
          """
        ]
      },
      %Variation{
        id: :fixed_width,
        template: template_fixed_width(),
        attributes: %{
          current_year: 2023,
          current_month: 11,
          selected_date: ~U[2023-11-24 00:00:00Z],
          day_content_fn: &__MODULE__.day_content/1
        },
        slots: [
          """
          """
        ]
      }
    ]
  end

  def day_content(_day) do
    HousekeepingBookWeb.CustomComponents.my_day_content(%{income: "1,000", expense: "4,000"})
  end
end
