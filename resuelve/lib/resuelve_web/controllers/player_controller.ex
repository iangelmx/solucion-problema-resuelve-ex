defmodule ResuelveWeb.PlayerController do
  use ResuelveWeb, :controller
  alias Resuelve.Helpers.PlayerHelper

  def calculate_salary(conn, %{"jugadores" => raw_players}) do
    player_list = PlayerHelper.sanitize_raw_player( raw_players )
    IO.inspect( elem(player_list, 1), label: "To return" )
    with {:ok, _} <- player_list do
      json(conn, %{ok: true, status_code: 200, description: "Deployed", received: raw_players})
    else
      _err -> json(conn, %{ok: false, status_code: 400, description: elem(player_list, 1)})
    end
  end
end
