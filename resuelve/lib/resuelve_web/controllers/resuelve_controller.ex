defmodule ResuelveWeb.ResuelveController do
	#alias Resuelve.Context.Jugador
	alias Resuelve.Helpers.JugadorHelper
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

		players_with_salary = JugadorHelper.get_final_salary_players( raw_players )
		final_players = JugadorHelper.format_output_players( players_with_salary )

		json(conn, %{ok: true, status_code: 200, jugadores: final_players})

	end
end
