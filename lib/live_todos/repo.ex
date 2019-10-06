defmodule LiveTodos.Repo do
  use Ecto.Repo,
    otp_app: :live_todos,
    adapter: Ecto.Adapters.Postgres
end
