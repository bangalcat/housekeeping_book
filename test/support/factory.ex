defmodule HousekeepingBook.Factory do
  alias HousekeepingBook.Repo

  alias HousekeepingBook.Schema.{
    User
  }

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
