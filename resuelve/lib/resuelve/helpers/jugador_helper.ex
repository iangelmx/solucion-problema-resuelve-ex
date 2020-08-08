defmodule Resuelve.Helpers.JugadorHelper do
  alias Resuelve.Context.Jugador

  def jugador_builder( %{"nombre" => nombre,
                          "nivel" => nivel,
                          "goles" => goles,
                          "sueldo" => sueldo,
                          "bono" => bono,
                          "sueldo_completo" => sueldo_completo,
                          "equipo" => equipo }  ) do
    %Jugador{
      nombre: nombre,
      nivel: nivel,
      goles: goles,
      sueldo: sueldo,
      bono: bono,
      sueldo_completo: sueldo_completo,
      equipo: equipo,
    }
  end

  #Separar funciones en archivos separados.
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


  def get_goles_de_equipo(  ) do

  end


  def get_alcance_global( jugador=%Jugador{} ) do
    JugadorHelper.get_scored_goals jugador
    Jugador.get_level(jugador) |> Jugador.get_goal_goals


  end

end
