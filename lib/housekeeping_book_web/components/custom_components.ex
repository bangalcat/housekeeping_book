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
  attr :patch, JS, default: nil
  attr :rest, :global, include: ~w(id)

  def card(assigns) do
    ~H"""
    <div class={["bg-white space-y-3 p-4 rounded-lg shadow", @class]} phx-click={@patch} {@rest}>
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
        <.label for={i.field.id} class="flex-none w-1/4 text-gray-700 dark:text-gray-100">
          <%= i.label %>
        </.label>
        <.input
          field={i.field}
          type={i.type}
          phx-debounce={120}
          class="flex-auto dark:text-white"
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

  attr :id, :string, default: "calendar"
  attr :current_month, :integer, default: 1
  attr :current_year, :integer, default: 2000
  attr :selected_date, Date
  attr :day_content_fn, :any, default: &__MODULE__.always_nil/1
  attr :day_click_event, :string, default: "day-click-event"
  attr :calendar_click_event, :string, default: "calendar-event"
  attr :class, :string
  slot :calendar_header

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
    <div id={@id} class={["md:p-4 py-3 px-1 rounded-t w-full flex", @class]}>
      <!-- Header -->
      <%= render_slot(@calendar_header) %>
      <!-- Calendar -->
      <div class="flex items-center justify-between pt-6 overflow-x-auto">
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
      "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-700 focus:bg-primary-400",
      "hover:bg-primary-400 text-base w-7 h-7 leading-tight flex items-center justify-center",
      "font-medium text-white bg-primary-500 rounded-full"
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

  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def floating_button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "p-0 w-10 h-10 bg-red-600 rounded-full hover:bg-red-700 active:shadow-lg mouse shadow",
        "transition ease-in duration-200 focus:outline-none",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :rest, :global, include: ~w(disabled form name value)

  slot :main_button, required: true do
    attr :class, :string
  end

  slot :left_button do
    attr :class, :string
  end

  slot :top_button do
    attr :class, :string
  end

  slot :middle_button do
    attr :class, :string
  end

  def floating_button_group(assigns) do
    ~H"""
    <div class="group fixed bottom-0 right-0 p-2 flex items-end justify-end w-24 h-24 ">
      <!-- main -->
      <div class={[
        "text-white shadow-xl flex items-center justify-center p-3 rounded-full",
        "bg-gradient-to-r from-cyan-500 to-blue-500 z-50 absolute"
      ]}>
        <%= render_slot(@main_button) %>
      </div>
      <!-- sub left -->
      <div
        :if={@left_button != []}
        class={[
          "absolute rounded-full transition-all duration-[0.2s] ease-out scale-y-0",
          "group-hover:scale-y-100 group-hover:-translate-x-16 flex p-2 hover:p-3 bg-green-300 scale-100 hover:bg-green-400 text-white"
        ]}
      >
        <%= render_slot(@left_button) %>
      </div>
      <!-- sub top -->
      <div
        :if={@top_button != []}
        class={[
          "absolute rounded-full transition-all duration-[0.2s] ease-out scale-x-0",
          "group-hover:scale-x-100 group-hover:-translate-y-16 flex p-2 hover:p-3 bg-blue-300 hover:bg-blue-400 text-white"
        ]}
      >
        <%= render_slot(@top_button) %>
      </div>
      <!-- sub middle -->
      <div
        :if={@middle_button != []}
        class={[
          "absolute rounded-full transition-all duration-[0.2s] ease-out scale-x-0 group-hover:scale-x-100",
          "group-hover:-translate-y-14 group-hover:-translate-x-14 flex p-2 hover:p-3 bg-yellow-300 hover:bg-yellow-400 text-white"
        ]}
      >
        <%= render_slot(@middle_button) %>
      </div>
    </div>
    """
  end
end
