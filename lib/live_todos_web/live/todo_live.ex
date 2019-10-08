defmodule LiveTodosWeb.TodoLive do
  use Phoenix.LiveView

  require Logger

  alias LiveTodos.Todos
  alias LiveTodos.Todos.Todo
  alias LiveTodosWeb.TodoView

  @postgres_channel "todos_changes"
  @channel_name "todos"

  @doc """
  Returns a supervisor child spec for the global Postgres notification listener.
  """
  def notification_listener do
    opts = [
      channel: @postgres_channel,
      mfa: {__MODULE__, :handle_todos_changes},
      schema: Todo
    ]

    {LiveTodos.NotificationListener, opts}
  end

  # Called by LiveTodosWeb.notification_listener
  def handle_todos_changes(channel, event_type, todo) do
    Logger.debug(
      "notification from postgres on #{inspect(channel)}: #{event_type} #{inspect(todo)}"
    )

    LiveTodosWeb.Endpoint.broadcast(@channel_name, event_type, todo)
  end

  # Called by LiveView.
  def mount(_conn, socket) do
    LiveTodosWeb.Endpoint.subscribe(@channel_name)

    result = socket |> refresh()
    {:ok, result}
  end

  # Called by LiveView.
  def render(assigns) do
    TodoView.render("todos.html", assigns)
  end

  # Called by LiveView.
  def handle_event("add", %{"todo" => todo}, socket) do
    Todos.create_todo(todo)
    {:noreply, socket}
  end

  def handle_event("toggle_done", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    Todos.update_todo(todo, %{done: !todo.done})
    {:noreply, socket}
  end

  # Called by PubSub.
  def handle_info(%Phoenix.Socket.Broadcast{event: "INSERT"} = msg, socket) do
    new_todos = [msg.payload | socket.assigns.todos]

    {:noreply, assign(socket, :todos, new_todos)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "UPDATE"} = msg, socket) do
    new_todos =
      Enum.map(socket.assigns.todos, fn todo ->
        if todo.id != msg.payload.id, do: todo, else: msg.payload
      end)

    {:noreply, assign(socket, :todos, new_todos)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "DELETE"} = msg, socket) do
    new_todos =
      Enum.reject(socket.assigns.todos, fn todo ->
        todo.id == msg.payload.id
      end)

    {:noreply, assign(socket, :todos, new_todos)}
  end

  defp refresh(socket) do
    assign(socket, todos: Todos.list_todos())
  end
end
