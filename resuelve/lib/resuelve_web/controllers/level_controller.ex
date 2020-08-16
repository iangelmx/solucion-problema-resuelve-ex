defmodule ResuelveWeb.LevelController do
  alias Resuelve.Helpers.LevelHelper
  use ResuelveWeb, :controller
  # Patern matching
  # Documentación -> Spec's
  # Add with struct
  # Test only helpers
  @spec index(map(), map()) :: map()
  def index(conn, _params) do
    levels = LevelHelper.get_current_levels()
    json(conn, %{ok: true, status_code: 200, levels: levels})
  end

  @spec create(map(), map()) :: map()
  def create(conn, %{"niveles" => levels}) do
    saved = LevelHelper.save_new_levels(levels)
    result = Enum.all?(saved, fn x -> x == :ok end)
    json(conn, %{ok: result, status_code: 200, description: %{levels_created: saved}})
  end

  @spec update(map(), map()) :: map()
  def update(conn, %{"niveles" => levels}) do
    updated = LevelHelper.update_received_levels(levels)
    result = Enum.all?(updated, fn x -> x == :ok end)
    json(conn, %{ok: result, status_code: 200, description: %{levels_updated: updated}})
  end

  def delete(conn, %{"niveles" => levels}) do
    deleted = LevelHelper.delete_received_levels(levels)
    result = Enum.all?(deleted, fn x -> x == :ok end)
    json(conn, %{ok: result, status_code: 200, description: %{levels_updated: deleted}})
  end
end
