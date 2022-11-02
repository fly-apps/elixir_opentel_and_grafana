alias Faker.Person
alias Faker.Lorem

alias FlyOtel.Accounts
alias FlyOtel.Accounts.TodoListItem
alias FlyOtel.Accounts.User

1..20
|> Enum.each(fn _ ->
  {:ok, %User{} = user} =
    Accounts.create_user(%{
      age: Enum.random(18..65),
      name: "#{Person.first_name()} #{Person.last_name()}"
    })

  1..Enum.random(5..50)
  |> Enum.each(fn _ ->
    {:ok, %TodoListItem{}} = Accounts.create_todo_list_item(%{task: Lorem.sentence()}, user)
  end)
end)
