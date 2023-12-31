defmodule HousekeepingBook.Flop.CustomFilters do
  @moduledoc false
  import Ecto.Query

  def date_month_filter(query, %Flop.Filter{value: value, op: :==}, _opts) do
    {year, month, timezone} = cast_value(value)
    start_date = DateTime.new!(Date.new!(year, month, 1), ~T[00:00:00], timezone)

    where(query, [r], r.date >= ^start_date and r.date < datetime_add(^start_date, 1, "month"))
  end

  defp cast_value(value) do
    case value do
      {year, month, timezone} when is_integer(year) and is_integer(month) ->
        {year, month, timezone}

      {%Date{} = date, timezone} ->
        {date.year, date.month, timezone}

      %Date{} = date ->
        {date.year, date.month, "Etc/UTC"}

      _ ->
        {nil, nil, "Etc/UTC"}
    end
  end
end
