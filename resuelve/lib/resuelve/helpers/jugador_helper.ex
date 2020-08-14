defmodule Resuelve.Helpers.JugadorHelper do
  alias Resuelve.Context.Jugador
  alias Resuelve.Helpers.EquiposHelper

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

  @spec get_level_goal_goals( nonempty_charlist() ) :: integer()
  def get_level_goal_goals( nivel ) when nivel != "" and nivel != nil do
    alias Resuelve.{Repo, Level}
    #result = Repo.all( from l in Level, where: l.level == ^"#{nivel}" ,select: [l.level, l.min_goals])
    result = Repo.get_by( Level, level: "#{nivel}")
    #IO.inspect(result, label: "Resulstado de DB")

    with %Resuelve.Level{min_goals: min_goals} <- result
      do
        min_goals
      else
        err -> err
    end
  end
  def get_level_goal_goals(_nivel) do
    nil
  end

  @spec get_player_goals_goal( %Jugador{} ) :: %Jugador{}
  def get_player_goals_goal( jugador = %Jugador{nivel: nivel} ) when nivel != "" and nivel != nil do
    goles_min = jugador	|> get_level |> get_level_goal_goals
    Map.put( jugador, :goles_minimos, goles_min )
  end
  def get_player_goals_goal( jugador = %Jugador{} ) do
    Map.put( jugador, :goles_minimos, 0 )
  end

  @spec calculate_single_compliance( %Jugador{} ) :: float()
  def calculate_single_compliance( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles == nil or goles_min == nil do
    nil
  end
  def calculate_single_compliance( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles >= goles_min and goles > 0 do
    100.0
  end
  def calculate_single_compliance( %Jugador{goles_minimos: goles_min, goles: goles } ) when goles < goles_min and goles > 0 do
    (goles * 100) / goles_min
  end
  def calculate_single_compliance(%Jugador{} ) do
    0.0
  end

  @spec get_single_compliance( %Jugador{} ) :: %Jugador{}
  def get_single_compliance(jugador = %Jugador{}) do
    alc_ind = calculate_single_compliance(jugador)
    Map.put(jugador, :alcance_ind, alc_ind)
  end

  @spec calcula_sueldo_completo( %Jugador{} ) :: float()
  def calcula_sueldo_completo( jugador = %Jugador{alcance_ind: alcance_ind, alcance_team: alcance_team} ) when alcance_ind != nil and alcance_team != nil do
    final_compliance = ((alcance_ind + alcance_team) / 2)
    jugador.sueldo + (jugador.bono * final_compliance)
  end
  def calcula_sueldo_completo(%Jugador{}) do
    0
  end


  @spec get_global_compliance( map() ) :: float()
  def get_global_compliance( %Jugador{alcance_ind: single_comp, alcance_team: team_comp } ) when single_comp != nil and team_comp != nil do
    (single_comp + team_comp) / 2
  end
  def get_global_compliance( %Jugador{} ) do
    nil
  end

  @spec calculate_bonus_part( float() , map() ) :: float()
  def calculate_bonus_part( global_compliance, %Jugador{bono: bonus} ) when bonus > 0 and bonus != nil and global_compliance > 0 and global_compliance != nil do
    bonus * global_compliance/100
  end
  def calculate_bonus_part( _global_compliance, %Jugador{} ) do
    nil
  end

  @spec calculate_salary( %Jugador{} ) :: float()
  def calculate_salary( jugador = %Jugador{sueldo: salary, bono: bonus} ) when bonus >0 and bonus != nil and salary != nil and salary > 0 do
    global_comp = jugador |> get_global_compliance
    final_bonus = calculate_bonus_part( global_comp, jugador )
    salary + final_bonus
  end
  def calculate_salary( %Jugador{sueldo: salary} ) when salary > 0 and salary != nil do
    salary
  end
  def calculate_salary( %Jugador{} )do
    nil
  end

  @spec check_if_failed( %Jugador{} ) :: boolean()
  def check_if_failed( %Jugador{sueldo_completo: sueldo_comp} ) when sueldo_comp < 0 or sueldo_comp == nil do
    true
  end
  def check_if_failed( %Jugador{} ) do
    false
  end

  @spec calculate_final_salary_players( list( %Jugador{} ) ) :: list()
  def calculate_final_salary_players( players_details ) do
    Enum.map( players_details, fn jugador ->
			salary = calculate_salary( jugador )
      player = Map.put(jugador, :sueldo_completo, salary)
      Map.put(player, :failed, check_if_failed(player))
		end)
  end

  @spec get_final_salary_players( list( %Jugador{} ) ) :: list()
  def get_final_salary_players( raw_players ) do
    players_with_min_goals = Enum.map(raw_players, fn jugador ->
			jugador = get_player_goals_goal( jugador )
			get_single_compliance(jugador)
		end )

		by_team = Enum.group_by(players_with_min_goals, fn(jugador)->jugador.equipo end)
		teams = Map.keys( by_team )

		team_results = Enum.map( teams, fn(equipo)->
			players_current_team = Map.fetch!(by_team, equipo)
			EquiposHelper.get_team_compliance(players_current_team)
		end )

    players_details = List.flatten( team_results )
    calculate_final_salary_players( players_details )
  end



  @spec take_only_necessary_attrs( %Jugador{} ) :: %Jugador{}
  def take_only_necessary_attrs( player ) do
      Map.take( player, [ :nombre,
                          :nivel,
                          :goles_minimos,
                          :goles,
                          :sueldo,
                          :bono,
                          :sueldo_completo,
                          :equipo ]
      )
  end

  @spec format_output_players( list( %Jugador{} ) ) :: map()
  def format_output_players( players_with_salary ) do
    failed_separated = Enum.group_by( players_with_salary,
      fn(jugador)->jugador.failed end,
      fn(jugador)-> take_only_necessary_attrs(jugador) end
    )

    with %{true: failed, false: sucess} <-failed_separated do
      %{ failed: failed, successfull: sucess}
    else
      _err -> with %{true: failed} <- failed_separated do
              %{ failed: failed}
            end
            with %{false: sucess} <- failed_separated do
              %{ successfull: sucess}
            end
    end


  end

end
