defmodule Jugador do
	defstruct [
		id: nil,
		nombre: "",
		nivel: "",
		goles: 0,
		sueldo: 0,
		bono: 0,
		sueldo_completo: nil,
		equipo: "",
		goles_min: nil,
		alcance_ind: nil,
		alcance_team: nil

	]

	def get_level( jugador = %Jugador{nivel: nivel} ) when nivel != "" do
		#IO.puts("El jugador es nivel #{jugador.nivel}")
		jugador.nivel
	end

	def get_level(%Jugador{}) do
		#IO.puts("Sin nivel asignado")
		""
	end

	def get_scored_goals( %Jugador{goles: goles} ) do
		#IO.puts("El jugador anotó #{jugador.goles} goles.")
		goles
	end

	#def get_goal_goals( jugador = %Jugador{nivel: nivel} ) when nivel != "" do
	def get_goal_goals( nivel ) when nivel != "" do
		import Ecto.Query
		alias Resuelve.{Repo, Level}
		result = Repo.all( from l in Level, where: l.level == ^"#{nivel}" ,select: [l.level, l.min_goals])
		Enum.at( Enum.at(result, 0 ), 1)
	end

	def get_goal_goals(%Jugador{})do
		#IO.puts("No tiene un nivel asignado")
		0
	end


	def calcula_alcance_equipo( {} ) do

	end


	def calcula_alcance_individual( %Jugador{goles_min: goles_min, goles: goles } ) when goles > goles_min do
		100
	end
	def calcula_alcance_individual( %Jugador{goles_min: goles_min, goles: goles } ) when goles < goles_min and goles > 0 do
		(goles * 100) / goles_min
	end
	def calcula_alcance_individual(%Jugador{} ) do
		0
	end


	def calcula_sueldo_completo( jugador = %Jugador{alcance_ind: alcance_ind, alcance_team: alcance_team} ) when alcance_ind != nil and alcance_team != nil do
		final_compliance = ((alcance_ind + alcance_team) / 2)
		jugador.sueldo + (jugador.bono * final_compliance)
	end

	def calcula_sueldo_completo(%Jugador{}) do
		IO.puts("No se tienen los alcances individual ni de equipo")
	end

end


defmodule ResuelveWeb.ResuelveController do
  use ResuelveWeb, :controller

	def calculate_salaries(conn, params) do
		# IO.puts("Decodificado:\n")
		# IO.puts( inspect(params["_json"]))
		# IO.puts("Fin de JSON\n\n")

		result = Enum.map params["_json"], fn(player) ->
			# IO.puts("Jugador X en ENUM\n")
			# IO.puts( inspect(player) )
			# IO.puts("\n")

			%Jugador{
				:nombre => player["nombre"],
				:nivel => player["nivel"],
				:goles => player["goles"],
				:sueldo => player["sueldo"],
				:bono => player["bono"],
				:sueldo_completo => player["sueldo_completo"],
				:equipo => player["equipo"],
			}
		end

		IO.puts( "Resultado ENUM:\n")
		IO.puts( inspect(result) )
		IO.puts("\n\n\n")

		meta_equipos = []
		scored_equipos = []
		teams = []

		Enum.map result,  fn(jugador) ->

			IO.puts( Jugador.get_scored_goals jugador )

			#IO.puts( Jugador.get_level(jugador) |> Jugador.get_goal_goals )

			index = Enum.find_index( teams, fn( team )->
				jugador.equipo == team
			end )

			#Calcular el alcance para cada jugador

			IO.puts("\n\n")
			if jugador.equipo in( teams ) do
				IO.puts("Equipo en teams")
				index = teams |> Enum.with_index |> Enum.each( fn({x, i})->
																							if jugador.equipo == i, do: x, else: :that
																						end )
				IO.puts("Index of equipo: #{jugador.equipo}: #{index}")
			else
				IO.puts("Equipo not in teams")
				teams = [teams |  jugador.equipo ]
				scored_equipos = [ scored_equipos | [ jugador.goles ]]
				meta_equipos = [ meta_equipos |  [Jugador.get_level(jugador) |> Jugador.get_goal_goals] ]
				IO.puts("Here...")
			end

		end

		IO.puts("Resultados ENUM:->>>>>>>>>>>>>>>>>>>>>\n")

		IO.puts(teams)
		IO.puts(scored_equipos)
		IO.puts(meta_equipos)
		IO.puts("Fin Resultados <-------------")

		json(conn, %{ok: true ,id: "Hey...", status_code: 200, body: params})

	end


end
