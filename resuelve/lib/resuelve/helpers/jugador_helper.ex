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
  @spec get_level( map() ) :: integer()
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

  def calcula_alcance_individual( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles > goles_min do
    100
  end
  def calcula_alcance_individual( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles < goles_min and goles > 0 do
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


  @spec get_alcance_global( map() ) :: float()
  def get_alcance_global( %Jugador{alcance_ind: single_comp, alcance_team: team_comp } ) do
    (single_comp + team_comp) / 2
  end

  @spec calculate_bonus_part( float(), map() ) :: float()
  def calculate_bonus_part( global_compliance, %Jugador{bono: bonus} ) do
    bonus * global_compliance/100
  end

  def calculate_salary( jugador = %Jugador{sueldo: salary, bono: bonus} ) when bonus >0 do
    global_comp = jugador |> get_alcance_global
    final_bonus = calculate_bonus_part( global_comp, jugador )
    salary + final_bonus
  end
  def calculate_salary( jugador = %Jugador{sueldo: salary} ) do
    salary
  end

end
