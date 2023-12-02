defmodule HousekeepingBook.Repo.Migrations.AddUsersTimezone do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :timezone, :string, default: "Etc/UTC"
    end

    execute "UPDATE users SET timezone = 'Etc/UTC' WHERE timezone IS NULL"
  end
end
