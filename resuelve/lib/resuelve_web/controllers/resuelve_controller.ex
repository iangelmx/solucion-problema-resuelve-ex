defmodule ResuelveWeb.ResuelveController do
	#alias Resuelve.Context.Jugador
	alias Resuelve.Helpers.JugadorHelper
	alias Resuelve.Helpers.EquiposHelper
	use ResuelveWeb, :controller

	#Patern matching
	#Documentación -> Spec's
	#Add with struct
	# Test only helpers
	@spec calculate_salaries( map(), map()  ) :: map()
	def calculate_salaries(conn, %{"jugadores" => jugadores } ) do

		raw_players = Enum.map( jugadores , fn(player) ->
			JugadorHelper.jugador_builder( player )
		end )

		players_with_min_goals = Enum.map(raw_players, fn jugador ->
			jugador = JugadorHelper.get_player_goals_goal( jugador )
			JugadorHelper.get_single_compliance(jugador)
		end )

		by_team = Enum.group_by(players_with_min_goals, fn(jugador)->jugador.equipo end)
		teams = Map.keys( by_team )

		#To parallelize:
		team_results = Enum.map( teams, fn(equipo)->
			players_current_team = Map.fetch!(by_team, equipo)
			EquiposHelper.get_team_compliance(players_current_team)
		end )

		players_details = List.flatten( team_results )
		players_with_salary = JugadorHelper.get_final_salary_players( players_details )

		final_players = JugadorHelper.format_output_players( players_with_salary )
		json(conn, %{ok: true, status_code: 200, jugadores: final_players})

	end
end
