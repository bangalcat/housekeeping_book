alias HousekeepingBook.Accounts

secret_code = Application.get_env(:housekeeping_book, :secret_code)

user_1 = %{
  name: "user1",
  email: "user1@example.com",
  type: :normal,
  password: "thisisfortest",
  password_confirmation: "thisisfortest",
  secret_code: secret_code
}

share_user = %{
  name: "share",
  email: "shared@example.com",
  type: :shared,
  password: "thisisfortest",
  password_confirmation: "thisisfortest",
  secret_code: secret_code
}

Accounts.User.register!(user_1)
Accounts.User.register!(share_user)
