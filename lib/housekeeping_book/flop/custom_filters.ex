defmodule HousekeepingBook.Flop.CustomFilters do
  import Ecto.Query

  def date_month_filter(query, %Flop.Filter{value: value, op: op}, opts) do
    source = Keyword.fetch!(opts, :source)
    {year, month} = cast_value(value)

    where(query, ^date_month_fragment(source, month, year, op))
  end

  defp cast_value(value) do
    case value do
      {year, month} when is_integer(year) and is_integer(month) -> {year, month}
      %Date{} = date -> {date.year, date.month}
      _ -> {nil, nil}
    end
  end

  defp date_month_fragment(source, month, year, :==) do
    dynamic(
      [r],
      fragment(
        "extract(month from ?) = ? and extract(year from ?) = ?",
        field(r, ^source),
        ^month,
        field(r, ^source),
        ^year
      )
    )
  end

  defp date_month_fragment(source, month, year, :>=) do
    dynamic(
      [r],
      fragment(
        "extract(month from ?) >= ? and extract(year from ?) = ?",
        field(r, ^source),
        ^month,
        field(r, ^source),
        ^year
      )
    )
  end

  defp date_month_fragment(source, month, year, :<=) do
    dynamic(
      [r],
      fragment(
        "extract(month from ?) <= ? and extract(year from ?) = ?",
        field(r, ^source),
        ^month,
        field(r, ^source),
        ^year
      )
    )
  end
end
