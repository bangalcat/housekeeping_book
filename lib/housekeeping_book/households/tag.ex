defmodule HousekeepingBook.Households.Tag do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  code_interface do
    define_for HousekeepingBook.Households
    define :read
    define :create
    define :update
    define :destroy
    define :get_by_id, action: :by_id, args: [:id]
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_id do
      get_by :id
    end
  end

  attributes do
    integer_primary_key :id
    attribute :name, :string, allow_nil?: false

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  postgres do
    table "tags"
    repo HousekeepingBook.Repo
  end
end
