defmodule HousekeepingBook.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias HousekeepingBook.Repo

  alias HousekeepingBook.Schema.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    from(Category)
    |> preload(:parent)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id) do
    from(Category)
    |> where([c], c.id == ^id)
    |> preload([c], :parent)
    |> Repo.one!()
  end

  def get_category_by_name_and_type(name, type) do
    Repo.get_by(Category, name: name, type: type)
  end

  def get_category_by_name_and_type!(name, type) do
    Repo.get_by!(Category, name: name, type: type)
  end

  def get_or_create_category(name, nil, type) do
    case get_category_by_name_and_type(name, type) do
      nil -> create_category(%{name: name, type: type})
      result -> {:ok, result}
    end
  end

  def get_or_create_category(name, parent_name, type) do
    case get_category_by_name_and_type(name, type) do
      nil ->
        with {:ok, parent} <- get_or_create_category(parent_name, nil, type) do
          create_category(%{parent_id: parent, name: name, type: type})
        end

      category ->
        {:ok, category}
    end
  end

  def create_categories(category_attrs) do
    now = DateTime.utc_now()

    category_attrs =
      Enum.map(
        category_attrs,
        &Map.merge(&1, %{inserted_at: {:placeholder, :now}, updated_at: {:placeholder, :now}})
      )

    Repo.insert_all(Category, category_attrs, placeholders: %{now: now})
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    changeset(category, attrs)
  end

  @doc false
  defp changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :type, :parent_id])
    |> validate_required([:name, :type])
  end

  @doc false
  def delete_all_categories() do
    Repo.delete_all(Category)
  end

  @spec bottom_categories() :: [Category.t()]
  def bottom_categories() do
    from(Category, as: :c)
    |> join(:left, [c: c], p in assoc(c, :parent), on: c.id == p.parent_id, as: :p)
    |> where([p: p], is_nil(p.id))
    |> Repo.all()
  end

  @spec category_type_options() :: [{String.t(), atom()}]
  def category_type_options do
    Ecto.Enum.values(Category, :type)
    |> Enum.map(fn type -> {Category.category_type_name(type), type} end)
  end

  def new_category(attrs \\ %{}) do
    Category.new(attrs)
  end

  def ensure_with_parent(category) do
    category
    |> Repo.preload(:parent)
  end
end
