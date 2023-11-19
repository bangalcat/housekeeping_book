defmodule HousekeepingBook.Records.Importer do
  alias HouseKeepingBook.Records.Record

  @callback import_records(source :: Enumerable.t(), opts :: keyword()) ::
              {:ok, [Record.t()]} | {:error, atom() | String.t()}
end
