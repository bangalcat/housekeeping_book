defmodule HousekeepingBook.RecordsImporter.CsvImporter do
  alias HousekeepingBook.Accounts
  alias HousekeepingBook.Households

  @behaviour HousekeepingBook.RecordsImporter

  @impl true
  def import_records(source, opts \\ []) do
    mapper = Keyword.get(opts, :mapper, fn _ -> [] end)

    source
    |> NimbleCSV.RFC4180.parse_stream()
    |> Stream.map(mapper)
    |> Ash.bulk_create(Households.Record, :create)
  end

  def my_mapper([
        date,
        category_1,
        category_2,
        category_3,
        description,
        income,
        expense,
        subject,
        payment,
        _tag
      ]) do
    date =
      Date.from_iso8601!(date)
      |> Date.to_gregorian_days()
      |> Kernel.*(86400)
      |> Kernel.+(86399)
      |> DateTime.from_gregorian_seconds()

    {type, amount} = parse_amount(income, expense)

    {:ok, subject_user} = get_subject(subject)

    category = get_category(category_1, category_2, category_3, type)

    %{
      date: date,
      description: description,
      amount: amount,
      subject: subject_user,
      category: category,
      payment: payment(payment)
    }
  end

  defp get_subject("공용") do
    with {:ok, user} <- Accounts.create_shared_user() do
      {:ok, user}
    end
  end

  defp get_subject(name) do
    with {:ok, user} <- Accounts.create_user(%{name: name, email: "#{name}@test.com"}) do
      {:ok, user}
    end
  end

  defp parse_amount("", expense) do
    {:expense, String.to_integer(expense)}
  end

  defp parse_amount(income, "") do
    {:income, String.to_integer(income)}
  end

  defp get_category(_category_1, _category_2, category_3, type) do
    Households.get_category_by_name_and_type!(category_3, type)
  end

  defp payment("현금"), do: :cash
  defp payment("신용카드"), do: :credit_card
  defp payment("체크카드"), do: :check_card
  defp payment("계좌이체"), do: :bank_transfer
  defp payment("페이"), do: :pay
end
