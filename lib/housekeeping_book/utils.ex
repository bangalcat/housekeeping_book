defmodule HousekeepingBook.Utils do
  import Ecto.Changeset

  @spec maybe_put_assoc(Ecto.Changeset.t(), map(), keyword()) :: Ecto.Changeset.t()
  def maybe_put_assoc(changeset, attrs, opts) do
    key = Keyword.fetch!(opts, :key)

    case attrs[key] || attrs["#{key}"] do
      nil -> changeset
      value -> changeset |> put_assoc(key, value)
    end
  end
end
