defmodule HousekeepingBook.Households.Preparations.DateMonthFilter do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    date_month = Ash.Query.get_argument(query, :date_month)
    timezone = Ash.Query.get_argument(query, :timezone)
    {year, month} = cast_value(date_month)
    start_date = DateTime.new!(Date.new!(year, month, 1), ~T[00:00:00], timezone)
    end_date = DateTime.new!(Date.end_of_month(start_date), ~T[23:59:59], timezone)
    Ash.Query.filter(query, date >= ^start_date and date < ^end_date)
  end

  defp cast_value(value) do
    case value do
      {year, month} when is_integer(year) and is_integer(month) ->
        {year, month}

      {year, month} when is_binary(year) and is_binary(month) ->
        {String.to_integer(year), String.to_integer(month)}

      %Date{} = date ->
        {date.year, date.month}

      _ ->
        {nil, nil}
    end
  end
end
