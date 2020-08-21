defmodule ResuelveWeb.LevelController do
  alias Resuelve.Helpers.LevelHelper
  use ResuelveWeb, :controller

  @doc """
  This endpoint is the responsible to show the teams and levels that are alredy
  registered to calculate salary of its players
  """
  @spec index(map(), map()) :: map()
  def index(conn, _params) do
    levels = LevelHelper.get_current_levels()
    json(conn, %{ok: true, status_code: 200, levels: levels})
  end

  @doc """
  Creates new levels or teams with levels in the database
  """
  @spec create(map(), map()) :: map()
  def create(conn, %{"niveles" => levels}) do
    res = LevelHelper.save_new_levels(levels)

    json(conn |> put_status(res[:status]), %{
      ok: res[:ok],
      status_code: res[:code],
      description: res[:desc]
    })
  end

  @doc """
  Update a specific level in a team inside the database
  """
  @spec update(map(), map()) :: map()
  def update(conn, %{"niveles" => levels}) do
    res = LevelHelper.update_received_levels(levels)

    json(conn |> put_status(res[:status]), %{
      ok: res[:ok],
      status_code: res[:code],
      description: res[:desc]
    })
  end

  @doc """
  This endpoint deletes the given levels according it team
  """
  @spec delete(Plug.Conn.t(), map) :: map()
  def delete(conn, %{"niveles" => levels}) do
    deleted = LevelHelper.delete_received_levels(levels)

    json(conn |> put_status(deleted[:status]), %{
      ok: deleted[:ok],
      status_code: deleted[:code],
      description: deleted[:desc]
    })
  end
end
