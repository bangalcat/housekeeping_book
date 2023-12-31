defmodule HousekeepingBookWeb.RecordLive.Monthly do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper
  require Logger

  alias HousekeepingBook.Records

  @impl true
  def mount(params, session, socket) do
    {timezone, timezone_offset} = get_timezone_with_offset(socket)

    if !params["year"] && !params["month"] do
      now = DateTime.utc_now() |> DateTime.shift_zone!(timezone || "Etc/UTC")
      {:ok, redirect(socket, to: ~p"/monthly/records/#{now.year}/#{now.month}")}
    else
      socket =
        socket
        |> assign_user_device(session)
        |> assign(:timezone, timezone)
        |> assign(:timezone_offset, timezone_offset)
        |> assign(:meta, nil)

      {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, url, socket) do
    year = params["year"] |> String.to_integer()
    month = params["month"] |> String.to_integer()
    timezone = socket.assigns.timezone || "Etc/UTC"
    now = DateTime.utc_now() |> DateTime.shift_zone!(timezone)
    curr_path = URI.parse(url).path

    Logger.debug("#{inspect(now)}, year, month")

    socket =
      socket
      |> assign(:current_path, curr_path)
      |> assign(:year, year)
      |> assign(:month, month)
      |> assign_list_records(year, month, timezone)
      |> assign_new(:selected_date, fn ->
        if year == now.year and month == now.month do
          Date.new!(year, month, now.day)
        else
          Date.new!(year, month, 1)
        end
      end)
      |> assign_daily_type_amount()

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:record, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Record")
    |> assign(:record, get_record!(id))
  end

  defp apply_action(socket, :new, _params) do
    datetime =
      if selected_date = socket.assigns.selected_date do
        DateTime.new!(selected_date, ~T[00:00:00], socket.assigns.timezone || "UTC")
      else
        DateTime.utc_now()
        |> DateTime.shift_zone!(socket.assigns.timezone || "UTC")
      end

    socket
    |> assign(:page_title, "New Record")
    |> assign(:record, new_record(datetime))
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/records?#{params}")}
  end

  def handle_event("calendar-click", %{"event" => event} = params, socket) do
    handle_calendar_event(event, params, socket)
  end

  def handle_event("go-to-today", _, socket) do
    date = Date.utc_today()

    socket =
      socket
      |> push_patch(to: ~p"/monthly/records/#{date.year}/#{date.month}")
      |> assign(:selected_date, select_date(date, socket.assigns.selected_date))
      |> maybe_scroll_to_date(date)

    {:noreply, socket}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, record}}, socket) do
    record = get_record!(record.id)
    {:noreply, stream_insert(socket, :records, record, at: 0)}
  end

  def assign_timezone(socket) do
    {timezone, offset} = get_timezone_with_offset(socket)

    socket
    |> assign(:timezone, timezone)
    |> assign(:timezone_offset, offset)
  end

  def day_content(day, daily_amount_map) do
    income = daily_amount_map[{day, :income}] |> format_amount()
    expense = daily_amount_map[{day, :expense}] |> format_amount()

    my_day_content(%{income: income, expense: expense})
  end

  def handle_calendar_event(month_event, _params, socket)
      when month_event in ["prev-month", "next-month"] do
    base_date =
      socket.assigns.selected_date || Date.new!(socket.assigns.year, socket.assigns.month, 1)

    updated_date =
      case month_event do
        "prev-month" ->
          prev_month(base_date)

        "next-month" ->
          next_month(base_date)
      end

    socket =
      socket
      |> assign(:selected_date, updated_date)

    {:noreply,
     push_patch(socket, to: ~p"/monthly/records/#{updated_date.year}/#{updated_date.month}")}
  end

  def handle_calendar_event("select-day", %{"date" => date}, socket) do
    date = Date.from_iso8601!(date)

    socket =
      socket
      |> assign(:selected_date, select_date(date, socket.assigns.selected_date))
      |> maybe_scroll_to_date(date)

    {:noreply, socket}
  end

  defp select_date(new_date, _selected_date), do: new_date

  def maybe_scroll_to_date(socket, %Date{} = date) do
    nearest_record = Records.get_nearest_date_record(date, socket.assigns.timezone)

    if nearest_record do
      push_event(socket, "scroll_to", %{id: "records-#{nearest_record.id}"})
    else
      socket
    end
  end

  defp next_month(%Date{day: day} = date) do
    days_this_month = Date.days_in_month(date)
    first_of_next = Date.add(date, days_this_month - day + 1)
    days_next_month = Date.days_in_month(first_of_next)
    Date.add(first_of_next, min(day, days_next_month) - 1)
  end

  defp prev_month(%Date{day: day} = date) do
    last_of_prev = Date.add(date, -day)
    days_prev_month = Date.days_in_month(last_of_prev)
    Date.add(last_of_prev, -days_prev_month + min(day, days_prev_month))
  end

  def assign_daily_type_amount(socket) do
    year = socket.assigns.year
    month = socket.assigns.month
    timezone = socket.assigns.timezone || "Etc/UTC"

    month_first =
      DateTime.new!(Date.new!(year, month, 1), ~T[00:00:00], timezone)

    {daily_amount_map, total} =
      Records.get_amount_sum_group_by_date_and_type(%{
        month_first: month_first,
        timezone: month_first.zone_abbr
      })
      |> Records.with_total()

    socket
    |> assign(:daily_amount_map, daily_amount_map)
    |> assign(:total_amount, total)
  end

  def assign_list_records(socket, year, month, timezone) do
    case list_records(year, month, timezone) do
      {:ok, {records, meta}} ->
        socket
        |> assign(%{meta: meta})
        |> stream(:records, records, reset: true)

      {:error, meta} ->
        socket
        |> assign(:meta, meta)
    end
  end

  def list_records(year, month, timezone) do
    params = %{
      filters: [
        %{field: :date_month, value: {year, month, timezone}}
      ],
      limit: 1000
    }

    case Records.list_records(params, %{
           with_category: true,
           with_subject: true,
           with_tags: true
         }) do
      {:ok, {records, meta}} ->
        {:ok, {records, meta}}

      {:error, meta} ->
        {:error, meta}
    end
  end

  def total_amount(assigns) do
    ~H"""
    <div class="">
      <span class="text-sm dark:text-zinc-100"><%= gettext("Income") %></span>
      <span class="text-green-500"><%= format_amount(@income) %></span>
    </div>
    <div class="">
      <span class="text-sm dark:text-zinc-100"><%= gettext("Expense") %></span>
      <span class="text-red-500"><%= format_amount(@expense) %></span>
    </div>
    """
  end
end
