defmodule HousekeepingBook.AccountsTest do
  use HousekeepingBook.DataCase

  import HousekeepingBook.AccountsFixtures
  import Swoosh.TestAssertions

  alias HousekeepingBook.Accounts

  describe "users" do
    test "list_users/0 returns all users" do
      user = user_fixture()
      assert [res_user] = Accounts.list_users!()
      assert_same_schema(user, res_user)
    end

    test "get_user_by_id!/1 returns the user with given id" do
      user = user_fixture()
      assert_same_schema(Accounts.get_user_by_id!(user.id), user)
    end
  end

  describe "register_user_with_password/1" do
    test "requires email and password to be set" do
      assert {:error,
              %Ash.Error.Invalid{
                errors: [
                  %Ash.Error.Changes.Required{field: :password},
                  %Ash.Error.Changes.Required{field: :password_confirmation},
                  %Ash.Error.Changes.Required{field: :email}
                ]
              }} =
               Accounts.register_user_with_password(%{})
    end

    test "validates email and password when given" do
      assert {:error,
              %Ash.Error.Invalid{
                errors: [
                  %Ash.Error.Changes.InvalidArgument{field: :password},
                  %Ash.Error.Changes.InvalidArgument{field: :password_confirmation}
                ]
              }} =
               Accounts.register_user_with_password(%{
                 email: "test@test.com",
                 password: "123456",
                 password_confirmation: "123456"
               })
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)

      assert {:error,
              %Ash.Error.Invalid{
                errors: [
                  %Ash.Error.Changes.InvalidAttribute{field: :email},
                  %Ash.Error.Changes.InvalidAttribute{field: :email}
                ]
              }} =
               Accounts.register_user_with_password(%{
                 email: too_long,
                 password: too_long,
                 password_confirmation: too_long
               })
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()

      assert {:error, %Ash.Error.Invalid{errors: [%{message: "has already been taken"}]}} =
               Accounts.register_user_with_password(%{
                 email: email,
                 password: "12341234",
                 password_confirmation: "12341234"
               })

      # Now try with the upper cased email too, to check that email case is ignored.
      assert {:error, %Ash.Error.Invalid{errors: [%{message: "has already been taken"}]}} =
               Accounts.register_user_with_password(%{
                 email: String.upcase(email.string),
                 password: "12341234",
                 password_confirmation: "12341234"
               })
    end

    test "registers users with a hashed password" do
      email = unique_user_email()

      assert {:ok, user} =
               Accounts.register_user_with_password(valid_user_attributes(email: email))

      assert user.email.string == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()

      %{user: user}
    end

    test "when succeed, it does not change email until confirmation link by email executed", %{
      user: user
    } do
      assert_email_sent(subject: "Confirmation instructions")
      assert {:ok, user} = Accounts.update_user_email(user, %{email: "changed@test.com"})
      assert user.email.string != "changed@test.com"

      assert_email_sent(fn email ->
        assert email.text_body =~ user.email.string
        assert [[url]] = Regex.scan(~r/(?:https?:\/\/.+)/, email.text_body)
        assert url =~ "auth/user/confirm_change"
        [_, token] = String.split(url, "confirm=")
        send(self(), token)
      end)

      assert_receive token

      assert {:ok, user} =
               Ash.Changeset.for_update(user, :confirm_change, confirm: token)
               |> Ash.update()

      assert user.email.string == "changed@test.com"
    end
  end

  describe "update_user_password/3" do
    setup [:setup_user]

    test "validates password", %{user: user, password: pswd} do
      {:error, %Ash.Error.Invalid{errors: errors}} =
        Accounts.update_user_password(user, %{
          current_password: pswd,
          password: "invalid",
          password_confirmation: "another"
        })

      assert [
               %Ash.Error.Changes.InvalidArgument{
                 field: :password,
                 message: "length must be greater than or equal to %{min}"
               }
             ] = errors
    end

    test "validates maximum values for password for security", %{user: user, password: pswd} do
      too_long = String.duplicate("db", 100)

      {:error, %Ash.Error.Invalid{errors: [error]}} =
        Accounts.update_user_password(user, %{
          current_password: pswd,
          password: too_long,
          password_confirmation: "1234"
        })

      assert %_{message: "length must be less than or equal to %{max}"} = error
    end

    test "validates current password", %{user: user} do
      new_password = valid_user_password()

      assert {:error, %Ash.Error.Forbidden{errors: [error]}} =
               Accounts.update_user_password(user, %{
                 current_password: "invalid",
                 password: new_password,
                 password_confirmation: new_password
               })

      assert %AshAuthentication.Errors.AuthenticationFailed{field: :current_password} = error
    end

    test "updates the password", %{user: user, password: pswd} do
      new_password = valid_user_password()

      assert {:ok, user} =
               Accounts.update_user_password(user, %{
                 current_password: pswd,
                 password: new_password,
                 password_confirmation: new_password
               })

      assert {:ok, [%Accounts.User{}]} =
               Ash.Query.for_read(Accounts.User, :sign_in_with_password, %{
                 email: user.email,
                 password: new_password
               })
               |> Ash.read()
    end
  end

  def setup_user(_) do
    password = valid_user_password()
    %{user: user_fixture(%{password: password}), password: password}
  end
end
