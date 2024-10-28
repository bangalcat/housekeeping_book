defmodule HousekeepingBook.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HousekeepingBook.Accounts` context.
  """

  @doc """
  Generate a user.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def unique_name, do: "user#{System.unique_integer()}"
  def valid_user_password, do: "hello world there#{System.unique_integer()}"

  def valid_user_attributes(attrs \\ %{}) do
    password = attrs[:password] || valid_user_password()

    Enum.into(attrs, %{
      email: unique_user_email(),
      password: password,
      password_confirmation: password
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> HousekeepingBook.Accounts.register_user_with_password()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
