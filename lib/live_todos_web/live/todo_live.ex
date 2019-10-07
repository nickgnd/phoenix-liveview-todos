defmodule LiveTodosWeb.TodoLive do
  use Phoenix.LiveView

  alias LiveTodos.Todos
  alias LiveTodosWeb.TodoView

  def mount(_session, socket) do
    Todos.subscribe()

    {:ok, fetch(socket)}
  end

  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)

    {:noreply, fetch(socket)}
  end

  # TODO: there is space for improvement here, instead of loading all the todos each time
  #       we can diff the todos (?)
  def handle_info({Todos, [:todo | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, todos: Todos.list_todos())
  end
end

