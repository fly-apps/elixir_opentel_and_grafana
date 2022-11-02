defmodule FlyOtel.Repo.Migrations.AddTodoListTable do
  use Ecto.Migration

  def change do
    create table(:todo_list_items) do
      add :task, :string, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
