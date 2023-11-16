defmodule HousekeepingBook.Schema.Tag do
  use HousekeepingBook.Schema.Base

  schema "tags" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

end
