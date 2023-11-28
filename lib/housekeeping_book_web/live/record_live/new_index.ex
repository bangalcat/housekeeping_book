defmodule HousekeepingBookWeb.RecordLive.NewIndex do
  use HousekeepingBookWeb, :live_view
  import HousekeepingBookWeb.RecordLive.Helper
  require Logger

  alias HousekeepingBook.Records

  @impl true
  def mount(_params, session, socket) do
    {timezone, _timezone_offset} = get_timezone_with_offset(socket)
    now = DateTime.utc_now() |> DateTime.shift_zone!(timezone || "UTC")

    socket =
      socket
      |> assign_list_records(now.year, now.month)
      |> assign_user_device(session)
      |> assign(:year, now.year)
      |> assign(:month, now.month)
      |> assign(:selected_date, DateTime.to_date(now))
      |> assign(:meta, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:record, nil)
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/records?#{params}")}
  end

  def handle_event("calendar-click", %{"event" => event} = params, socket) do
    handle_calendar_event(event, params, socket)
  end

  defp select_date(date, date), do: nil
  defp select_date(new_date, _selected_date), do: new_date

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, record}}, socket) do
    record = get_record!(record.id)
    {:noreply, stream_insert(socket, :records, record)}
  end

  def assign_timezone(socket) do
    {timezone, offset} = get_timezone_with_offset(socket)

    socket
    |> assign(:timezone, timezone)
    |> assign(:timezone_offset, offset)
  end

  def day_content(day, records_map) do
    records = records_map[day] || []

    income = get_amount_sum(records, :income)
    expense = get_amount_sum(records, :expense)

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
      |> assign(:year, updated_date.year)
      |> assign(:month, updated_date.month)
      |> assign_list_records(updated_date.year, updated_date.month)
      |> assign(:selected_date, socket.assigns.selected_date && updated_date)

    {:noreply, socket}
  end

  def handle_calendar_event("select-day", %{"date" => date}, socket) do
    date = Date.from_iso8601!(date)

    socket =
      socket
      |> assign(:selected_date, select_date(date, socket.assigns.selected_date))
      |> maybe_scroll_to_date(date)

    {:noreply, socket}
  end

  def maybe_scroll_to_date(socket, %Date{} = date) do
    nearest_record = find_nearest_record(socket.assigns.records_map, date)

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

  def assign_list_records(socket, year, month) do
    case list_records(year, month) do
      {:ok, {records, meta}} ->
        socket
        |> assign(%{meta: meta})
        |> stream(:records, records)
        |> assign_records_map(records)

      {:error, meta} ->
        socket
        |> assign(:meta, meta)
    end
  end

  def list_records(year, month) do
    params = %{
      filters: [
        %{field: :date_month, value: {year, month}}
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

  def assign_records_map(socket, records) do
    records_map =
      Enum.reduce(records, %{}, fn record, acc ->
        key = DateTime.to_date(record.date)
        Map.update(acc, key, [record], &([record] ++ &1))
      end)

    socket
    |> assign(:records_map, records_map)
  end
end
