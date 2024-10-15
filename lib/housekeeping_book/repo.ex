defmodule HousekeepingBook.Repo do
  use Boundary, deps: []

  use AshPostgres.Repo,
    otp_app: :housekeeping_book,
    adapter: Ecto.Adapters.Postgres

  def transact(fun, opts \\ []) do
    transaction(
      fn repo ->
        Function.info(fun, :arity)
        |> case do
          {:arity, 0} -> fun.()
          {:arity, 1} -> fun.(repo)
        end
        |> case do
          :ok -> :no_result
          {:ok, result} -> result
          :error -> repo.rollback(:no_reason)
          {:error, reason} -> repo.rollback(reason)
        end
      end,
      opts
    )
  end

  def installed_extensions() do
    ["citext", "ash-functions"]
  end

  def min_pg_version do
    %Version{major: 17, minor: 0, patch: 0}
  end
end
