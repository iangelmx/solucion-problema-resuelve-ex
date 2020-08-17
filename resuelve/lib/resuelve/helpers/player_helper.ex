defmodule Resuelve.Helpers.PlayerHelper do
  alias Resuelve.Contexts.LevelManager
  alias Resuelve.Helpers.TeamHelper


  @spec get_minimum_player_goals( map(), charlist()|nil ) :: integer()
  def get_minimum_player_goals( players, team_name) do
    Enum.map( players, fn(player) ->
      min_goals = LevelManager.get_minimum_goals_by_level( player.level, team_name )
      Map.put(player, :min_goals, min_goals)
    end)
  end

  @spec calculate_complete_salary_for_players( map() ) :: float()
  def calculate_single_compliance_player( %{goles: goles, min_goals: min_goals} ) when goles >= min_goals do
    100.0
  end
  def calculate_single_compliance_player( %{goles: goles, min_goals: min_goals} ) when goles < min_goals when min_goals > 0 do
    goles * 100 / min_goals
  end
  def calculate_single_compliance_player( _player )do
    0.0
  end

  @spec get_single_compliance_players( list( map()), charlist()) :: list( map() )
  def get_single_compliance_players( players, team_name ) do
    get_minimum_player_goals( players, team_name )
    |> Enum.map( fn(player)->
        s_c = calculate_single_compliance_player(player)
        Map.put( player, :single_compliance, s_c)
    end)
  end



  @spec calculate_complete_salary_for_players( map(), charlist()|nil) :: list( map() )
  def calculate_teams_compliance( players ) do
    by_team = Enum.group_by( players, fn(player) -> player.equipo end)
    teams = Map.keys( by_team )
    Enum.map( teams, fn(team) ->
      Map.fetch( by_team, team )
      |> TeamHelper.calculate_compliance_by_team
    end )
    by_team
  end

  def calculate_global_compliance( players, team_name) do
    players = get_single_compliance_players( players, team_name )
    calculate_teams_compliance( players)
  end

  @spec calculate_complete_salary_for_players(list(map()), charlist()|nil) :: list()
  def calculate_complete_salary_for_players(player_list, team_name) do
    IO.puts("HEy...")
    # Enum.map(player_list)
    # Calcula alcance global
    calculate_global_compliance( player_list, team_name )
    # Calcula alcande individual
    # Calcula alcance grupal
    # Calcula salario final
    # Formatea la salida
  end

end
