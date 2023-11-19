defmodule HousekeepingBook.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias HousekeepingBook.Repo

  alias HousekeepingBook.Schema.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_or_create_user_by_type(type) do
    case Repo.get_by(User, type: type) do
      nil -> create_user(%{type: type, name: "share", email: nil})
      user -> {:ok, user}
    end
  end

  def get_or_create_user_by_name(name) do
    case Repo.get_by(User, name: name) do
      nil -> create_user(%{type: :normal, name: name, email: nil})
      user -> {:ok, user}
    end
  end

  def get_user_by_type!(type) do
    Repo.get_by!(User, type: type)
  end

  def get_user_by_name!(name) do
    Repo.get_by!(User, name: name)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> user_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> user_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    user_changeset(user, attrs)
  end

  @doc false
  defp user_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :type])
    |> validate_required([:name, :type])
    |> validate_format(:email, ~r/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}/)
  end
end
