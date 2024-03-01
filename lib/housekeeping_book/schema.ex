defmodule HousekeepingBook.Schema do
  use Boundary,
    deps: [],
    exports: [Record, Category, Tag, User, UserToken]
end
