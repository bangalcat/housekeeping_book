defmodule HousekeepingBook.Households.Tag do
  use Ash.Resource,
    domain: HousekeepingBook.Households,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define :read
    define :create
    define :update
    define :destroy
  end

  actions do
    defaults [:read, :create, :update, :destroy]
    default_accept [:name]

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
