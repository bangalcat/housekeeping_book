defmodule HousekeepingBookWeb.RecordLive.Helper do
  import HousekeepingBook.Gettext

  alias HousekeepingBook.Records
  alias HousekeepingBook.Categories
  alias HousekeepingBook.Accounts
  alias HousekeepingBook.Schema.Record
  alias HousekeepingBook.Schema.Category
  alias HousekeepingBook.Schema.User

  def record_options() do
    categories = Categories.bottom_categories() |> Enum.map(&category_option/1)
    subjects = Accounts.list_users() |> Enum.map(&subject_option/1)
    category_types = Categories.category_type_options()
    payment_types = Records.record_payment_options()

    %{
      category: categories,
      subject: subjects,
      payment: payment_types,
      category_type: category_types,
      payment_type: payment_types
    }
  end

  defp category_option(%Category{} = category) do
    {"#{category.name} (#{category.type})", category.id}
  end

  defp subject_option(%User{} = subject) do
    {subject.name, subject.id}
  end

  def category_name(%{category: nil}), do: nil
  def category_name(%{category: %{name: name}}), do: name

  def category_type(%{category: nil}), do: nil

  def category_type(%{category: %{type: type}}) do
    case type do
      :expense -> gettext("Expense")
      :income -> gettext("Income")
    end
  end

  def payment_name(payment) do
    Record.payment_enum_name(payment)
  end

  def subject_name(%{subject: nil}), do: nil
  def subject_name(%{subject: %{name: name}}), do: name

  def tags(%{tags: nil}), do: nil
  def tags(%{tags: tags}), do: Enum.join(tags, ", ")
end
