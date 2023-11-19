defmodule HousekeepingBook.TestUtils do
  @spec same_fields?(map(), map(), list()) :: boolean()
  def same_fields?(a, b, keys) when is_map(a) and is_map(b) and is_list(keys) do
    Enum.all?(keys, &Kernel.==(Map.fetch!(a, &1), Map.fetch!(b, &1)))
  end

  @spec same_schema?(Ecto.Schema.t(), Ecto.Schema.t()) :: boolean()
  def same_schema?(a, b) do
    with true <- a.__struct__ == b.__struct__,
         primary_keys <- a.__struct__.__schema__(:primary_key),
         true <- same_fields?(a, b, primary_keys) do
      true
    else
      _ -> false
    end
  end

  def assert_same_schema(a, b) do
    unless same_schema?(a, b) do
      raise ExUnit.AssertionError,
        message: "The two records have different primary keys",
        left: a,
        right: b
    end
  end
end
