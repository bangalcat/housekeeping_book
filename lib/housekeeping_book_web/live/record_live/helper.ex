defmodule HousekeepingBookWeb.RecordLive.Helper do
  use Gettext, backend: HousekeepingBook.Gettext
  import Phoenix.LiveView, only: [get_connect_params: 1]

  require Logger

  alias HousekeepingBook.Households

  alias HousekeepingBook.Records
  alias HousekeepingBook.Categories
  alias HousekeepingBook.Accounts
  alias HousekeepingBook.Schema.Record
  alias HousekeepingBook.Schema.User

  def record_options() do
    subjects = Accounts.list_users() |> Enum.map(&subject_option/1)
    category_types = Categories.category_type_options()
    payment_types = Records.record_payment_options()

    %{
      subject: subjects,
      payment: payment_types,
      category_type: category_types,
      payment_type: payment_types
    }
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
  def tags(%{tags: tags}) when is_list(tags), do: Enum.join(tags, ", ")
  def tags(%{}), do: nil

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
    # Record.new(datetime)
    %Households.Record{date: datetime, category: nil, subject: nil}
  end

  def get_record!(id) do
    Ash.get!(Households.Record, id, load: [:category, :subject, :tags])
  end

  def get_timezone_with_offset(%{assigns: %{current_user: %User{} = user}}) when user != nil do
    {user.timezone,
     DateTime.utc_now()
     |> DateTime.shift_zone!(user.timezone)
     |> Map.get(:utc_offset)
     |> then(&div(&1, 3600))}
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

  def change_record(record, params \\ %{}, opts \\ [])

  def change_record(%HousekeepingBook.Schema.Record{} = record, params, _opts) do
    Records.change_record(record, params)
  end

  def change_record(%Households.Record{} = record, params, opts) do
    record
    |> for_create_or_update(params, opts[:live_action] || :new)
  end

  defp for_create_or_update(record, params, live_action) do
    case live_action do
      :edit ->
        record
        |> AshPhoenix.Form.for_update(:update,
          as: "record",
          prepare_params: &prepare_params/2,
          domain: Households
        )
        |> AshPhoenix.Form.validate(params)

      :new ->
        Households.Record
        |> AshPhoenix.Form.for_create(:create,
          as: "record",
          prepare_params: &prepare_params/2,
          domain: Households
        )
        |> AshPhoenix.Form.validate(params)
    end
  end

  defp prepare_params(%{"date" => date, "timezone" => timezone} = params, :validate) do
    date = Households.cast_datetime_with_timezone(date, timezone)

    params
    |> Map.put("date", date)
  end

  defp prepare_params(params, :validate), do: params

  def delete_record!(record) do
    Households.Record.delete!(record)
  end
end
