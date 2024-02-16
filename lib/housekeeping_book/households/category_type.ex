defmodule HousekeepingBook.Households.CategoryType do
  use Ash.Type.Enum, values: [:income, :expense, :saving]

  def category_type_name(:income), do: "수입"
  def category_type_name(:expense), do: "지출"
  def category_type_name(:saving), do: "저축"
end
