defmodule HousekeepingBook.Repo.Migrations.AddCategoryToRecords do
  use Ecto.Migration

  def change do
    alter table(:records) do
      add :category_id, references(:categories, on_delete: :nothing)
      add :tag_ids, {:array, :integer}
    end
  end
end
