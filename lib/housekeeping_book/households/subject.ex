defmodule HousekeepingBook.Households.Subject do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read]
  end

  attributes do
    integer_primary_key :id
    attribute :name, :string
    attribute :email, :string

    attribute :type, :atom, constraints: [one_of: [:shared, :normal, :admin]], default: :normal
    attribute :timezone, :string, default: "Etc/UTC"
  end

  postgres do
    table "users"
    repo HousekeepingBook.Repo
    migrate? false
  end
end
