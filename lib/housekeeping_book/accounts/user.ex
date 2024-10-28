defmodule HousekeepingBook.Accounts.User do
  use Ash.Resource,
    domain: HousekeepingBook.Accounts,
    extensions: [AshAuthentication],
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  code_interface do
    define :update
  end

  actions do
    defaults [:read, :destroy]

    read :by_id do
      get_by :id
    end

    read :list_users do
    end

    create :create do
      accept [:name, :email, :type]
      upsert? true
      upsert_identity :unique_email
    end

    create :create_shared do
      accept [:email]
      upsert? true
      upsert_identity :unique_email

      change set_attribute(:name, "share")
      change set_attribute(:type, :share)
      change set_new_attribute(:email, "shared@example.com")
    end

    update :update do
      accept [:name, :type, :timezone]
      require_atomic? false
      require_attributes [:name, :type]
      action_select [:name, :type, :timezone]
    end

    update :update_email do
      accept [:email]
      require_atomic? false

      validate changing(:email)
    end

    update :update_password do
      require_atomic? false
      argument :current_password, :string, sensitive?: true, allow_nil?: false

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8, max_length: 72
        sensitive? true
      end

      argument :password_confirmation, :string do
        description "The proposed password for the user (again), in plain text."
        allow_nil? false
        sensitive? true
      end

      change set_context(%{strategy_name: :password})

      # Hashes the provided password
      change AshAuthentication.Strategy.Password.HashPasswordChange

      # validates that the password matches the confirmation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation,
        only_when_valid?: true

      validate {AshAuthentication.Strategy.Password.PasswordValidation,
                password_argument: :current_password},
               only_when_valid?: true
    end

    read :by_session_token do
      get? true
      argument :token, :string, allow_nil?: false

      prepare fn query, context ->
        token = Ash.Query.get_argument(query, :token)
        nil
      end
    end

    read :sign_in_with_password do
      description "Attempt to sign in using a email and password."
      get? true

      argument :email, :ci_string do
        description "The email to use for retrieving the user."
        allow_nil? false
      end

      argument :password, :string do
        description "The password to check for the matching user."
        allow_nil? false
        sensitive? true
      end

      # validates the provided email and password and generates a token
      prepare AshAuthentication.Strategy.Password.SignInPreparation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    read :sign_in_with_token do
      # In the generated sign in components, we generate a validate the
      # email and password directly in the LiveView
      # and generate a short-lived token that can be used to sign in over
      # a standard controller action, exchanging it for a standard token.
      # This action performs that exchange. If you do not use the generated
      # liveviews, you may remove this action, and set
      # `sign_in_tokens_enabled? false` in the password strategy.

      description "Attempt to sign in using a short-lived sign in token."
      get? true

      argument :token, :string do
        description "The short-lived sign in token."
        allow_nil? false
        sensitive? true
      end

      # validates the provided sign in token and generates a token
      prepare AshAuthentication.Strategy.Password.SignInWithTokenPreparation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    create :register_with_password do
      description "Register a new user with a email and password."
      accept [:email]

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        description "The proposed password for the user (again), in plain text."
        allow_nil? false
        sensitive? true
      end

      # Hashes the provided password
      change AshAuthentication.Strategy.Password.HashPasswordChange

      # Generates an authentication token for the user
      change AshAuthentication.GenerateTokenChange

      # validates that the password matches the confirmation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      metadata :token, :string do
        description "A JWT that can be used to authenticate the user."
        allow_nil? false
      end
    end

    action :request_password_reset do
      description "Send password reset instructions to a user if they exist."

      argument :email, :ci_string do
        allow_nil? false
      end

      # creates a reset token and invokes the relevant senders
      run {AshAuthentication.Strategy.Password.RequestPasswordReset, action: :get_by_email}
    end

    read :get_by_email do
      description "Looks up a user by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    update :reset_password do
      require_atomic? false

      argument :reset_token, :string do
        allow_nil? false
        sensitive? true
      end

      argument :password, :string do
        description "The proposed password for the user, in plain text."
        allow_nil? false
        constraints min_length: 8
        sensitive? true
      end

      argument :password_confirmation, :string do
        description "The proposed password for the user (again), in plain text."
        allow_nil? false
        sensitive? true
      end

      # validates the provided reset token
      validate AshAuthentication.Strategy.Password.ResetTokenValidation

      # validates that the password matches the confirmation
      validate AshAuthentication.Strategy.Password.PasswordConfirmationValidation

      # Hashes the provided password
      change AshAuthentication.Strategy.Password.HashPasswordChange

      # Generates an authentication token for the user
      change AshAuthentication.GenerateTokenChange
    end
  end

  authentication do
    tokens do
      enabled? true
      token_resource HousekeepingBook.Accounts.Token

      signing_secret fn _, _ ->
        Application.fetch_env(:housekeeping_book, :token_signing_secret)
      end

      add_ons do
        confirmation :confirm_new_user do
          monitor_fields [:email]
          confirm_on_create? true
          confirm_on_update? false
          sender HousekeepingBook.Accounts.User.Senders.SendNewUserConfirmationEmail
        end

        confirmation :confirm_change do
          monitor_fields [:email]
          confirm_on_create? false
          confirm_on_update? true
          confirm_action_name :confirm_change
          sender HousekeepingBook.Accounts.User.Senders.SendEmailChangeConfirmationEmail
        end
      end
    end

    strategies do
      password :password do
        identity_field :email

        resettable do
          sender HousekeepingBook.Accounts.User.Senders.SendPasswordResetEmail
        end
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string, allow_nil?: false, default: "noname"

    attribute :email, :ci_string do
      allow_nil? false
      constraints match: ~r/^[^\s]+@[^\s]+$/, max_length: 80
      public? true
    end

    attribute :hashed_password, :string do
      sensitive? true
      allow_nil? false
    end

    attribute :type, :atom, constraints: [one_of: [:shared, :normal, :admin]], default: :normal
    attribute :timezone, :string, default: "Etc/UTC"

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      # forbid_if always()
      authorize_if always()
    end
  end

  identities do
    identity :unique_email, [:email], eager_check_with: HousekeepingBook.Accounts
  end

  postgres do
    table "users"
    repo HousekeepingBook.Repo

    custom_indexes do
      index [:email], unique: true
    end
  end
end
