defmodule LiveTodos.Repo.Migrations.AddTodosNotifyTriggers do
  use Ecto.Migration
  def change do
    execute(
      """
      CREATE OR REPLACE FUNCTION notify_todos_changes()
      RETURNS trigger AS $$
      DECLARE
        current_row RECORD;
      BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
          current_row := NEW;
        ELSE
          current_row := OLD;
        END IF;
      PERFORM pg_notify(
          'todos_changes',
          json_build_object(
            'table', TG_TABLE_NAME,
            'type', TG_OP,
            'id', current_row.id,
            'data', row_to_json(current_row)
          )::text
        );
      RETURN current_row;
      END;
      $$ LANGUAGE plpgsql;
      """,
      """
      DROP FUNCTION notify_todos_changes;
      """
    )

    execute(
      """
      CREATE TRIGGER notify_todos_changes_trg
      AFTER INSERT OR UPDATE OR DELETE
      ON todos
      FOR EACH ROW
      EXECUTE PROCEDURE notify_todos_changes();
      """,
      """
      DROP TRIGGER notify_todos_changes_trg ON todos;
      """
    )
  end
end
