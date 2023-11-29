defmodule HousekeepingBookWeb.RecordLive.Helper do
  import HousekeepingBook.Gettext
  import Phoenix.LiveView, only: [get_connect_params: 1]

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
      :expense -> gettext("지출")
      :income -> gettext("수입")
    end
  end

  def payment_name(payment) do
    Record.payment_enum_name(payment)
  end

  def subject_name(%{subject: nil}), do: nil
  def subject_name(%{subject: %{name: name}}), do: name

  def tags(%{tags: nil}), do: nil
  def tags(%{tags: tags}), do: Enum.join(tags, ", ")

  def format_amount(%{amount: amount}) do
    format_amount(amount)
  end

  def format_amount(nil), do: nil

  def format_amount(amount) do
    HousekeepingBook.Cldr.Number.to_string!(amount, format: :currency, currency: :from_locale)
  end

  def format_datetime(record, timezone \\ nil)
  def format_datetime(%{date: nil}, _timezone), do: nil

  def format_datetime(%{date: date}, timezone) do
    date
    |> convert_timezone(timezone)
    |> HousekeepingBook.Cldr.DateTime.to_string!(format: :short)
  end

  def format_date(record, timezone \\ nil)
  def format_date(%{date: nil}, _timezone), do: nil

  def format_date(%{date: date}, timezone) do
    date
    |> convert_timezone(timezone)
    |> HousekeepingBook.Cldr.Date.to_string!(format: :short)
  end

  def convert_timezone(date, nil), do: date

  def convert_timezone(date, timezone) do
    date |> DateTime.shift_zone!(timezone)
  end

  def new_record(date \\ DateTime.utc_now())

  def new_record(nil), do: new_record(DateTime.utc_now())

  def new_record(%DateTime{} = datetime) do
    Record.new(datetime)
  end

  def get_record!(id) do
    Records.get_record!(id, %{with_category: true, with_subject: true, with_tags: true})
  end

  def get_timezone_with_offset(socket) do
    {get_connect_params(socket)["timezone"], get_connect_params(socket)["timezone_offset"]}
  end

  def get_amount_sum(records, category_type) do
    records
    |> Enum.filter(&(&1.category.type == category_type))
    |> Enum.map(& &1.amount)
    |> Enum.sum()
    |> then(fn
      0 -> nil
      amount -> format_amount(amount)
    end)
  end

  def find_nearest_record(records_map, date) when is_map_key(records_map, date),
    do: records_map[date] |> hd()

  def find_nearest_record(records_map, date) do
    records_map
    |> Enum.filter(fn {key, _} -> Date.compare(key, date) != :gt end)
    |> Enum.sort_by(fn {key, _} -> Date.diff(date, key) end)
    |> case do
      [] -> nil
      [{_date, [record | _]} | _] -> record
    end
  end
end
