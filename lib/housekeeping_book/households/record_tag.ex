defmodule HousekeepingBook.Households.RecordTag do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    table "record_tags"
    repo HousekeepingBook.Repo
  end

  relationships do
    belongs_to :record, HousekeepingBook.Households.Record, primary_key?: true, allow_nil?: false
    belongs_to :tag, HousekeepingBook.Households.Tag, primary_key?: true, allow_nil?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end
