defmodule HousekeepingBook.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :amount, :integer
      add :description, :string
      add :date, :utc_datetime
      add :subject_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:records, [:subject_id])
  end
end
