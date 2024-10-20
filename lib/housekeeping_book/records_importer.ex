defmodule HousekeepingBook.RecordsImporter do
  use Boundary, deps: [HousekeepingBook.Accounts, HousekeepingBook.Households], exports: :all

  alias HouseKeepingBook.Households.Record

  @callback import_records(source :: Enumerable.t(), opts :: keyword()) ::
              {:ok, [Record.t()]} | {:error, atom() | String.t()}
end
