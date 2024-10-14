defmodule HousekeepingBook.Accounts.User do
  use Ash.Resource,
    domain: HousekeepingBook.Accounts,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define :get_by_id, action: :by_id, args: [:id]

    define :list_users
    define :delete, action: :destroy
    define :register
    define :update_user_email
    define :update
  end

  actions do
    defaults [:read, :destroy, :create, :update]

    read :by_id do
      get_by :id
    end

    read :list_users do
    end

    create :register do
      accept [:name, :type, :email]

      require_attributes [:name, :type, :email]
      upsert_identity :unique_email
      upsert? true

      argument :password, :string do
        allow_nil? false
        constraints min_length: 12, max_length: 72
      end

      argument :password_confirmation, :string, allow_nil?: false
      argument :secret_code, :string

      validate confirm(:password, :password_confirmation)

      # temporarily validate secret code
      validate fn changeset, _ ->
        secret_code = Ash.Changeset.get_argument(changeset, :secret_code) || ""

        if secret_code == Application.get_env(:housekeeping_book, :secret_code) do
          :ok
        else
          {:error, field: :secret_code, message: "invalid secret code"}
        end
      end

      # hash password
      change before_action(fn changeset, _ ->
               password = Ash.Changeset.get_argument(changeset, :password)

               Ash.Changeset.change_attribute(
                 changeset,
                 :hashed_password,
                 Bcrypt.hash_pwd_salt(password)
               )
             end)
    end

    # TODO: update user_token first
    update :update_user_email do
      accept [:email]
      require_atomic? false

      argument :token, :struct do
        constraints instance_of: HousekeepingBook.Accounts.UserToken
        allow_nil? false
      end

      change before_action(fn changeset, _ ->
               token = Ash.Changeset.get_argument(changeset, :token)
             end)
    end

    # TODO: remove user_tokens first
    update :update_user_password do
    end

    read :by_session_token do
      get? true
      argument :token, :string, allow_nil?: false

      prepare fn query, context ->
        token = Ash.Query.get_argument(query, :token)
        nil
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string

    attribute :email, :ci_string do
      allow_nil? false
      constraints match: ~r/^[^\s]+@[^\s]+$/, max_length: 160
    end

    attribute :hashed_password, :string do
      sensitive? true
      allow_nil? false
    end

    attribute :confirmed_at, :utc_datetime
    attribute :type, :atom, constraints: [one_of: [:shared, :normal, :admin]], default: :normal
    attribute :timezone, :string, default: "Etc/UTC"

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_email, [:email]
  end

  postgres do
    table "users"
    repo HousekeepingBook.Repo

    custom_indexes do
      index [:email], unique: true
    end
  end
end
