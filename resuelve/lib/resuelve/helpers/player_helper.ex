defmodule Resuelve.Helpers.PlayerHelper do
  alias Resuelve.Contexts.LevelManager
  alias Resuelve.Helpers.TeamHelper

  @spec get_minimum_player_goals(list(map()), charlist() | nil) :: list(map())
  def get_minimum_player_goals(player_list, team_name) do
    Enum.map(player_list, fn player ->
      min_goals = LevelManager.get_minimum_goals_by_level(player.nivel, team_name)
      Map.put(player, :goles_minimos, min_goals)
    end)
  end

  @spec calculate_single_compliance_player(map()) :: float()
  def calculate_single_compliance_player(%{goles: goles, goles_minimos: min_goals})
      when goles >= min_goals do
    100.0
  end

  def calculate_single_compliance_player(%{goles: goles, goles_minimos: min_goals})
      when goles < min_goals
      when min_goals > 0 do
    goles * 100 / min_goals
  end

  def calculate_single_compliance_player(_player) do
    0.0
  end

  @spec get_single_compliance_players(list(map()), charlist()) :: list(map())
  def get_single_compliance_players(player_list, team_name) do
    get_minimum_player_goals(player_list, team_name)
    |> Enum.map(fn player ->
      s_c = calculate_single_compliance_player(player)
      Map.put(player, :single_compliance, s_c)
    end)
  end

  @spec calculate_teams_compliance(list(map())) :: list(map())
  def calculate_teams_compliance(player_list) do
    by_team = Enum.group_by(player_list, fn player -> player.equipo end)
    teams = Map.keys(by_team)

    Enum.map(teams, fn team ->
      Map.fetch!(by_team, team)
      |> TeamHelper.get_compliance_by_team()
    end)
  end

  @spec calculate_global_single_player(map()) :: float()
  def calculate_global_single_player(%{single_compliance: sc, team_compliance: tc}) do
    (sc + tc) / 2
  end

  @spec calculate_global_compliance(list(map())) :: list(map())
  def calculate_global_compliance(player_list) do
    Enum.map(player_list, fn player ->
      g_c = calculate_global_single_player(player)
      Map.put(player, :global_compliance, g_c)
    end)
  end

  @spec get_global_compliance_players(list(map()), charlist()) :: list(map())
  def get_global_compliance_players(player_list, team_name) do
    get_single_compliance_players(player_list, team_name)
    |> calculate_teams_compliance
    |> List.flatten()
    |> calculate_global_compliance
  end

  @spec calculate_final_salary(map()) :: number()
  def calculate_final_salary(%{bono: bonus, sueldo: salary, global_compliance: g_c}) do
    salary + bonus * g_c / 100
  end

  def get_final_salary(player_list) do
    Enum.map(player_list, fn player ->
      salary = calculate_final_salary(player)
      Map.put(player, :sueldo_completo, salary)
    end)
  end

  @spec take_only_necessary_attrs(map()) :: map()
  def take_only_necessary_attrs(player) do
    Map.take(player, [
      :nombre,
      :nivel,
      :goles_minimos,
      :goles,
      :sueldo,
      :bono,
      :sueldo_completo,
      :equipo
    ])
  end

  @spec format_output(list(map())) :: list(map())
  def format_output(player_list) do
    Enum.map(player_list, fn player -> take_only_necessary_attrs(player) end)
  end

  @spec calculate_complete_salary_for_players(list(map()), charlist() | nil) :: list()
  def calculate_complete_salary_for_players(player_list, team_name) do
    get_global_compliance_players(player_list, team_name)
    |> get_final_salary
    |> format_output
  end
end
