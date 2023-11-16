defmodule HousekeepingBook.Repo do
  use Boundary, deps: []

  use Ecto.Repo,
    otp_app: :housekeeping_book,
    adapter: Ecto.Adapters.Postgres
end
