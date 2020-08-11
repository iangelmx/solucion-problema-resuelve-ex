defmodule Resuelve.Helpers.JugadorHelper do
  alias Resuelve.Context.Jugador

  @spec jugador_builder( map() ) :: %Jugador{}
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

  @spec get_level( map() ) :: nonempty_charlist()
  def get_level( %Jugador{nivel: nivel} ) when nivel != "" do
    nivel
  end
  def get_level(%Jugador{}) do
    ""
  end

  @spec get_scored_goals( %Jugador{} ) :: integer()
  def get_scored_goals( %Jugador{goles: goles} ) do
    goles
  end

  @spec get_level_goal_goals( nonempty_charlist() ) :: integer()
  def get_level_goal_goals( nivel ) when nivel != "" do
    import Ecto.Query
    alias Resuelve.{Repo, Level}
    result = Repo.all( from l in Level, where: l.level == ^"#{nivel}" ,select: [l.level, l.min_goals])
    Enum.at( Enum.at(result, 0 ), 1)
  end
  def get_level_goal_goals(_nivel) do
    0
  end

  @spec get_single_compliance( %Jugador{} ) :: %Jugador{}
  def get_single_compliance(jugador = %Jugador{}) do
    alc_ind = calcula_alcance_individual(jugador)
    Map.put(jugador, :alcance_ind, alc_ind)
  end

  @spec calcula_alcance_individual( %Jugador{} ) :: float()
  def calcula_alcance_individual( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles > goles_min do
    100.0
  end
  def calcula_alcance_individual(%Jugador{} ) do
    0.0
  end
  def calcula_alcance_individual( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles < goles_min and goles > 0 do
    (goles * 100) / goles_min
  end


  @spec get_player_goals_goal( %Jugador{} ) :: %Jugador{}
  def get_player_goals_goal( jugador = %Jugador{nivel: nivel} ) when nivel != "" do
    goles_min = jugador	|> get_level |> get_level_goal_goals
    Map.put( jugador, :goles_minimos, goles_min )
  end
  def get_player_goals_goal( jugador = %Jugador{} ) do
    Map.put( jugador, :goles_minimos, 0 )
  end


  @spec calcula_sueldo_completo( %Jugador{} ) :: float()
  def calcula_sueldo_completo( jugador = %Jugador{alcance_ind: alcance_ind, alcance_team: alcance_team} ) when alcance_ind != nil and alcance_team != nil do
    final_compliance = ((alcance_ind + alcance_team) / 2)
    jugador.sueldo + (jugador.bono * final_compliance)
  end
  def calcula_sueldo_completo(%Jugador{}) do
    0
  end


  @spec get_alcance_global( map() ) :: float()
  def get_alcance_global( %Jugador{alcance_ind: single_comp, alcance_team: team_comp } ) do
    (single_comp + team_comp) / 2
  end

  @spec calculate_bonus_part( float(), map() ) :: float()
  def calculate_bonus_part( global_compliance, %Jugador{bono: bonus} ) do
    bonus * global_compliance/100
  end

  @spec calculate_salary( %Jugador{} ) :: float()
  def calculate_salary( jugador = %Jugador{sueldo: salary, bono: bonus} ) when bonus >0 do
    global_comp = jugador |> get_alcance_global
    final_bonus = calculate_bonus_part( global_comp, jugador )
    salary + final_bonus
  end
  def calculate_salary( %Jugador{sueldo: salary} ) do
    salary
  end

  @spec get_final_salary_players( list( %Jugador{} ) ) :: list()
  def get_final_salary_players( players_details ) do
    Enum.map( players_details, fn jugador ->
			salary = calculate_salary( jugador )
			Map.put(jugador, :sueldo_completo, salary)
		end)
  end

  @spec format_output_players( list( %Jugador{} ) ) :: list()
  def format_output_players( players_with_salary ) do
    Enum.map( players_with_salary, fn jugador ->
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
  end

end
