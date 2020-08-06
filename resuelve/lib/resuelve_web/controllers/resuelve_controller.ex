defmodule ResuelveWeb.ResuelveController do
  use ResuelveWeb, :controller



  def calculate_salaries(conn, params) do
		IO.puts("Parametros:")
		IO.puts(inspect(params))
		IO.puts("Fin parámetros")
		IO.puts("Decodificado:\n")
		#IO.puts(params._json)

		Enum.map elem(params,1), fn(player) ->
			IO.puts("Jugador X en ENUM\n")
			IO.puts( inspect(player) )
			IO.puts("\n")
		end

		json(conn, %{ok: true ,id: "Hey...", status_code: 200, body: params})

	end


end

defmodule Jugador do
	@derive Phoenix.Param
	defstruct [
		id: nil,
		nombre: "",
		nivel: "",
		goles: 0,
		sueldo: 0,
		bono: 0,
		sueldo_completo: nil,
		equipo: ""
	]
end
