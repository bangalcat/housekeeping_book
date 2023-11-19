defmodule HousekeepingBook.Schema.Base do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @type t :: %__MODULE__{}
    end
  end
end
