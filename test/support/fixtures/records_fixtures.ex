defmodule HousekeepingBook.RecordsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HousekeepingBook.Records` context.
  """

  @doc """
  Generate a record.
  """
  def record_fixture(attrs \\ %{}, user, category) do
    {:ok, record} =
      attrs
      |> Enum.into(%{
        amount: 42,
        date: ~U[2023-11-15 05:48:00Z],
        description: "some description",
        payment: :cash,
        subject_id: user.id,
        category_id: category.id
      })
      |> HousekeepingBook.Households.Record.create()

    record
    |> Ash.load!([:category, :subject])
  end
end
