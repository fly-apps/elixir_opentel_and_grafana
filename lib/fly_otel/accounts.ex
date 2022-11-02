defmodule FlyOtel.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias FlyOtel.Accounts.TodoListItem
  alias FlyOtel.Accounts.User
  alias FlyOtel.Repo

  @doc """
  Returns the list of users with an N+1 query.
  """
  def list_users_bad_perf do
    User
    |> Repo.all()
    |> Enum.map(fn %User{} = user ->
      num_todo_list_items =
        user
        |> Repo.preload(:todo_list_items)
        |> Map.get(:todo_list_items)
        |> length()

      {user, num_todo_list_items}
    end)
  end

  @doc """
  Returns the list of users without performing an N+1
  """
  def list_users_good_perf do
    query =
      from user in User,
        join: todo_list_items in assoc(user, :todo_list_items),
        group_by: user.id,
        select: {user, count(todo_list_items.id)}

    Repo.all(query)
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
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a Todo list item.
  """
  def create_todo_list_item(attrs \\ %{}, %User{} = user) do
    %TodoListItem{}
    |> TodoListItem.changeset(attrs, user)
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
    |> User.changeset(attrs)
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
    User.changeset(user, attrs)
  end
end
