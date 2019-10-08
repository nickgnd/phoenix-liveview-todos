defmodule LiveTodos.NotificationListener do
  @moduledoc """
  Spawns a connection to Postgres and issues a LISTEN command.
  """

  use GenServer
  alias LiveTodos.Repo

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    channel = Keyword.fetch!(opts, :channel)
    mfa = Keyword.fetch!(opts, :mfa)
    schema = Keyword.fetch!(opts, :schema)

    # I think this process should be global if there were multiple channels.
    {:ok, pid} = Postgrex.Notifications.start_link(Repo.config())
    {:ok, ref} = Postgrex.Notifications.listen(pid, channel)

    {:ok, %{mfa: mfa, schema: schema, pid: pid, ref: ref}}
  end

  @impl true
  def handle_info({:notification, _, _, channel, payload}, state) do
    decoded = Jason.decode!(payload)

    decoded["data"]
    |> to_json(state.schema)
    |> call_mfa(state, channel, decoded["type"])

    {:noreply, state}
  end

  defp to_json(payload, schema) do
    %{__struct__: schema}
    |> Ecto.Changeset.cast(payload, schema.__schema__(:fields))
    |> Ecto.Changeset.apply_changes()
  end

  defp call_mfa(record, %{mfa: {mod, fun}}, channel, event_type) do
    apply(mod, fun, [channel, event_type, record])
  end
end
