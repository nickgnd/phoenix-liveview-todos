defmodule LiveTodosWeb.PageController do
  use LiveTodosWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
