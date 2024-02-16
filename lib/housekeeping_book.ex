defmodule HousekeepingBook do
  use Boundary,
    deps: [Ecto, Ecto.Changeset, Ecto.Repo, Ecto.Schema],
    exports: [Accounts, Records, Categories, Tags, {Schema, []}, Repo, Gettext, {Households, []}]

  @moduledoc """
  HousekeepingBook keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end
