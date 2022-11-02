defmodule FlyOtel.Accounts.User do
  @moduledoc """
  This module contains the Ecto Schema definition for the user table along with
  supporting changesets.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias FlyOtel.Accounts.TodoListItem

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :age, :integer
    field :name, :string

    has_many :todo_list_items, TodoListItem

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
  end
end
