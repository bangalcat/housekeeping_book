defmodule HousekeepingBook.Repo.Migrations.AddUsersTimezone do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :timezone, :string, default: "Etc/UTC"
    end
  end
end
