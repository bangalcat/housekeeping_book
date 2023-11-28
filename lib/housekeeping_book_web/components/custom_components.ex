defmodule HousekeepingBookWeb.CustomComponents do
  use Phoenix.Component

  import Flop.Phoenix
  import HousekeepingBookWeb.CoreComponents
  import Phoenix.HTML.Tag

  slot :card_header
  slot :card_body
  slot :card_footer
  attr :class, :string, default: ""
  attr :body_class, :string, default: ""
  attr :header_class, :string, default: ""
  attr :footer_class, :string, default: ""
  attr :rest, :global, include: ~w(id)

  def card(assigns) do
    ~H"""
    <div class={["bg-white space-y-3 p-4 rounded-lg shadow", @class]} {@rest}>
      <div class={["flex items-center space-x-2 text-sm dark:text-slate-50", @header_class]}>
        <%= render_slot(@card_header) %>
      </div>
      <div class={["flex flex-wrap justify-stretch dark:text-slate-100", @body_class]}>
        <%= render_slot(@card_body) %>
      </div>
      <div class={["text-sm font-medium dark:text-slate-200", @footer_class]}>
        <%= render_slot(@card_footer) %>
      </div>
    </div>
    """
  end

  attr :meta, Flop.Meta, required: true
  attr :id, :string, default: nil
  attr :on_change, :string, default: "update-filter"
  attr :target, :string, default: nil
  attr :fields, :list
  attr :rest, :global, include: ~w(class)

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form
      for={@form}
      id={@id}
      phx-target={@target}
      phx-change={@on_change}
      phx-submit={@on_change}
      {@rest}
    >
      <.filter_fields :let={i} form={@form} fields={@fields}>
        <.input
          field={i.field}
          label={i.label}
          type={i.type}
          phx-debounce={120}
          class="flex-auto"
          {i.rest}
        />
      </.filter_fields>

      <.button class="my-2" name="reset" type="reset">reset</.button>
    </.form>
    """
  end

  def pagination_opts do
    [
      ellipsis_attrs: [class: "hero-ellipsis-horizontal"],
      ellipsis_content: "‥",
      next_link_attrs: [class: "hover:text-zinc-700"],
      next_link_content: next_icon(),
      page_links: {:ellipsis, 5},
      pagination_list_attrs: [class: "flex justify-center gap-12"],
      pagination_link_attrs: [class: "pagination-link"],
      pagination_link_aria_label: &"Go to #{&1}",
      previous_link_attrs: [class: "hover:text-zinc-700"],
      previous_link_content: previous_icon(),
      wrapper_attrs: [class: "flex justify-center gap-4"]
    ]
  end

  defp next_icon do
    content_tag(:span, "", class: "hero-chevron-right")
  end

  defp previous_icon do
    content_tag(:span, "", class: "hero-chevron-left")
  end

  def table_opts do
    [
      container: true,
      container_attrs: [class: "table-container"],
      no_results_content: content_tag(:p, do: "Nothing found."),
      table_attrs: [class: "my-table"],
      tbody_attrs: [class: "my-table-body"],
      thead_attrs: [class: "my-thead"],
      tbody_td_attrs: [class: "my-tbody-td"],
      tbody_tr_attrs: [class: "my-tbody-tr"]
    ]
  end

  @months ~w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

  attr :current_month, :integer, default: 1
  attr :current_year, :integer, default: 2000
  attr :selected_date, Date
  attr :day_content_fn, :any, default: &__MODULE__.always_nil/1
  attr :month_click_event, :string, default: "month-click-event"
  attr :day_click_event, :string, default: "day-click-event"
  attr :prev_month_event, :string, default: "prev-month-click"
  attr :next_month_event, :string, default: "next-month-click"
  attr :calendar_click_event, :string, default: "calendar-event"
  attr :class, :string

  def calendar(%{current_year: y, current_month: m} = assigns)
      when m in 1..12 and y in 1900..2100 do
    first_day = Date.new!(y, m, 1)
    dow = Date.day_of_week(first_day)
    blank_days_before = List.duplicate(nil, dow - 1)
    end_day = Date.days_in_month(first_day)

    weeks =
      blank_days_before
      |> Enum.concat(Date.range(first_day, Date.new!(y, m, end_day)))
      |> Enum.chunk_every(7, 7, Stream.cycle([nil]))

    assigns = Map.put(assigns, :weeks, weeks) |> Map.put(:months, @months)

    ~H"""
    <div class={["md:p-8 py-3 px-1 dark:bg-gray-800 bg-white rounded-t w-full", @class]}>
      <!-- Top Bar -->
      <div class="px-4 flex items-center justify-between">
        <!-- Month Year -->
        <span
          tabindex="0"
          class="focus:outline-none text-base dark:text-gray-100 text-gray-800 cursor-pointer hover:text-gray-400"
          phx-click={@calendar_click_event}
          phx-value-event={@month_click_event}
        >
          <span class="text-lg font-bold"><%= Enum.at(@months, @current_month - 1) %></span>
          <span><%= @current_year %></span>
        </span>
        <!-- Arrow Buttons -->
        <div class="flex items-center">
          <button
            type="button"
            aria-label="calendar backward"
            class="focus:text-gray-400 hover:text-gray-400 text-gray-800 dark:text-gray-100"
            phx-click={@calendar_click_event}
            phx-value-event={@prev_month_event}
          >
            <.icon name="hero-chevron-left" />
          </button>
          <button
            type="button"
            aria-label="calendar forward"
            class="focus:text-gray-400 hover:text-gray-400 ml-3 text-gray-800 dark:text-gray-100"
            phx-click={@calendar_click_event}
            phx-value-event={@next_month_event}
          >
            <.icon name="hero-chevron-right" />
          </button>
        </div>
      </div>
      <!-- Calendar -->
      <div class="flex items-center justify-between pt-12 overflow-x-auto">
        <table class="w-full table-fixed">
          <thead>
            <tr>
              <th :for={w <- ~w(Mo Tu We Th Fr Sa Su)} class="last-of-type:text-red">
                <div class="w-full flex justify-center">
                  <p class="text-base font-medium text-center text-gray-800 dark:text-gray-100">
                    <%= w %>
                  </p>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr :for={days <- @weeks}>
              <.day
                :for={day <- days}
                date={day}
                selected?={@selected_date && day && Date.compare(day, @selected_date) == :eq}
                calendar_click_event={@calendar_click_event}
                day_click_event={@day_click_event}
              >
                <:day_content :if={day}>
                  <%= @day_content_fn.(day) %>
                </:day_content>
              </.day>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  attr :date, Date
  attr :selected?, :boolean, default: false
  attr :day_click_event, :string, required: true
  attr :calendar_click_event, :string, required: true
  slot :day_content

  def day(assigns) do
    ~H"""
    <td class="align-top h-14">
      <div
        :if={@date}
        id={@date}
        class="px-1 cursor-pointer flex flex-col w-full justify-center items-center"
        phx-click={@calendar_click_event}
        phx-value-event={@day_click_event}
        phx-value-date={@date}
      >
        <p class={[
          "text-base text-gray-500 dark:text-gray-100 font-medium hover:text-gray-400 my-1",
          if(@selected?, do: focus_day_class())
        ]}>
          <%= @date.day %>
        </p>
        <%= render_slot(@day_content) %>
      </div>
    </td>
    """
  end

  defp focus_day_class,
    do: [
      "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 focus:bg-second",
      "hover:bg-second text-base w-8 h-8 flex items-center justify-center",
      "font-medium text-white bg-primary rounded-full"
    ]

  def always_nil(_), do: nil

  attr :income, :string
  attr :expense, :string

  def my_day_content(assigns) do
    ~H"""
    <div class="flex flex-col w-full text-center">
      <span :if={@income} class="text-green-500 text-xs whitespace-nowrap">
        <%= @income %>
      </span>
      <span :if={@expense} class="text-red-500 text-xs whitespace-nowrap">
        -<%= @expense %>
      </span>
    </div>
    """
  end
end
