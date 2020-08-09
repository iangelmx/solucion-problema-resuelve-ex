defmodule ResuelveWeb.ResuelveController do
	#alias Resuelve.Context.Jugador
	alias Resuelve.Helpers.JugadorHelper
	alias Resuelve.Helpers.EquiposHelper
	use ResuelveWeb, :controller

	#Patern matching
	#Documentación -> Spec's
	@spec calculate_salaries( map(), map()  ) :: map()
	def calculate_salaries(conn, %{"jugadores" => jugadores } ) do

		result = Enum.map( jugadores , fn(player) ->
			JugadorHelper.jugador_builder( player )
		end )

		jugadores_con_bono = Enum.map(result, fn jugador ->

			goles_min = jugador	|> JugadorHelper.get_level |> JugadorHelper.get_goal_goals
			jugador = Map.put( jugador, :goles_minimos, goles_min )

			alc_ind = JugadorHelper.calcula_alcance_individual(jugador)

			Map.put(jugador, :alcance_ind, alc_ind)

		end )

		por_equipo = Enum.group_by(jugadores_con_bono, fn(jugador)->jugador.equipo end)
		equipos = Map.keys( por_equipo )
		#IO.inspect(equipos, label: "Equipos")

		resultados_equipos = Enum.map( equipos, fn(equipo)->
			jugadores_team = Map.fetch!(por_equipo, equipo)

			team_goal = jugadores_team |> EquiposHelper.get_scored_and_goal_goals_team |> EquiposHelper.get_team_compliance

			Enum.map( jugadores_team, fn(jugador)->
				Map.put( jugador, :alcance_team, team_goal )
			end )
		end )

		jugadores_detalles = List.flatten( resultados_equipos )
		#IO.inspect(jugadores_detalles, label: "Resultados Equipos")
		jugadores_pago = Enum.map( jugadores_detalles, fn jugador ->
			salary = JugadorHelper.calculate_salary( jugador )
			Map.put(jugador, :sueldo_completo, salary)
		end)
		IO.inspect(jugadores_pago, label: "Jugadores con sueldo")

		final_players = Enum.map( jugadores_pago, fn jugador ->
			Map.take( jugador, [:nombre,
													:nivel,
													:goles_minimos,
													:goles,
													:sueldo,
													:bono,
													:sueldo_completo,
													:equipo ]
			)
		end)



		json(conn, %{ok: true ,id: "Hey...", status_code: 200, body: final_players})

	end
end
