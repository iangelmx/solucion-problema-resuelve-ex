defmodule ResuelveWeb.PlayerController do
  use ResuelveWeb, :controller
  alias Resuelve.Helpers.PlayerHelper
  alias Resuelve.Helpers.SanitizePlayerHelper

  @spec calculate_salary(Plug.Conn.t(), map()) :: map()
  def calculate_salary(conn, params) do
    player_list = SanitizePlayerHelper.sanitize_raw_player(params["jugadores"])
    team_name = params["equipo"]

    with %{ok: players, errors: players_with_errors} <- player_list do
      %{players: players_salary, errors: p_errors} =
        PlayerHelper.calculate_complete_salary_for_players(players, team_name)

      json(conn, %{
        ok: true,
        status_code: 200,
        description: %{
          jugadores: players_salary,
          with_errors: %{
            input_errors: players_with_errors,
            level_errors: p_errors
          }
        }
      })
    else
      _err ->
        json(conn |> put_status(:bad_request), %{
          ok: false,
          status_code: 400,
          description: player_list
        })
    end
  end
end
