defmodule HousekeepingBook.Factory do
  alias HousekeepingBook.Repo

  alias HousekeepingBook.Schema.{
    Record,
    Category,
    Tag,
    User
  }

  def build(:record) do
    %Record{
      id: unique_id(),
      date: ~U[2023-11-15 05:48:00Z],
      description: "some description",
      amount: 4200,
      payment: :other
    }
  end

  def build(:category) do
    %Category{
      id: unique_id(),
      name: "some category"
    }
  end

  def build(:tag) do
    %Tag{
      id: unique_id(),
      name: "some tag"
    }
  end

  def build(:user) do
    %User{
      id: unique_id(),
      type: :normal,
      name: "some user",
      email: "some@abc.com"
    }
  end

  def build(name, attrs \\ %{}) do
    name |> build() |> struct!(attrs)
  end

  def insert!(name, attrs \\ %{}) do
    name |> build(attrs) |> Repo.insert!()
  end

  defp unique_id do
    System.unique_integer([:positive, :monotonic])
  end
end
