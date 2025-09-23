defmodule HousekeepingBook.Repo do
  use Boundary, deps: []

  use AshPostgres.Repo,
    otp_app: :housekeeping_book,
    adapter: Ecto.Adapters.Postgres

  def installed_extensions() do
    ["citext", "ash-functions"]
  end

  def min_pg_version do
    %Version{major: 17, minor: 0, patch: 0}
  end
end
