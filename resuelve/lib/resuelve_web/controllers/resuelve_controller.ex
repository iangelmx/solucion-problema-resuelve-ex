defmodule ResuelveWeb.ResuelveController do
	alias Resuelve.Context.Jugador
	alias Resuelve.Helpers.JugadorHelper
	use ResuelveWeb, :controller

	#Patern matching
	#Documentación -> Spec's
	@spec calculate_salaries( map(), map()  ) :: map()
	def calculate_salaries(conn, %{"jugadores" => jugadores } ) do

		result = Enum.map jugadores, fn(player) ->

		end

		con_bono = Enum.map(result, fn jugador ->

			level = JugadorHelper.get_level(jugador)
			goles_min = JugadorHelper.get_goal_goals(level)
			jugador = Map.put( jugador, :goles_min, goles_min )

			IO.inspect( jugador, label: "Valor de jugador actual" )

			alc_ind = JugadorHelper.calcula_alcance_individual(jugador)
			IO.inspect( alc_ind, label: "Alcance individual..." )

			jugador = Map.put(jugador, :alcance_ind, alc_ind)

		end )

		por_equipo = Enum.group_by(con_bono, fn(jugador)->jugador.equipo end)

		IO.inspect(por_equipo, label: "Grupos de jugadores por equipo")

		json(conn, %{ok: true ,id: "Hey...", status_code: 200, body: params})

	end
end
