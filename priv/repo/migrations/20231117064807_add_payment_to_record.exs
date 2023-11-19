defmodule HousekeepingBook.Repo.Migrations.AddPaymentToRecord do
  use Ecto.Migration

  def change do
    alter table(:records) do
      add :payment, :string
    end
  end
end
