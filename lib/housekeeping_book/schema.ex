defmodule HousekeepingBook.Schema do
  use Boundary, deps: [], exports: [User, UserToken]
end
