defmodule FlyOtel.Accounts.TodoListItem do
  @moduledoc """
  This module contains the Ecto Schema definition for the todo_list_items table along with
  supporting changesets.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias FlyOtel.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todo_list_items" do
    field :task, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = todo_list_item, attrs, %User{} = user) do
    todo_list_item
    |> cast(attrs, [:task])
    |> validate_required([:task])
    |> put_assoc(:user, user)
  end
end
