defmodule Resuelve.Helpers.PlayerHelper do
  alias Resuelve.Contexts.LevelManager
  alias Resuelve.Helpers.TeamHelper

  @spec get_min_player_goals(list(map()), charlist() | nil) :: list(map())
  def get_min_player_goals(player_list, team_name) do
    Enum.map(player_list, fn player ->
      with {:ok, min_goals} <- LevelManager.get_minimum_goals_by_level(player.nivel, team_name) do
        Map.put(player, :goles_minimos, min_goals)
      else
        {:error, error} -> {:error, error <> " para jugador #{player[:nombre]}"}
      end
    end)
  end

  @spec calculate_indiv_comp_single_player(map()) :: float()
  def calculate_indiv_comp_single_player(%{goles: goles, goles_minimos: min_goals})
      when goles >= min_goals and min_goals > 0 and not is_nil(goles) and
             not is_nil(min_goals) do
    100.0
  end

  def calculate_indiv_comp_single_player(%{goles: goles, goles_minimos: min_goals})
      when goles < min_goals and min_goals > 0 and goles > 0 and not is_nil(goles) and
             not is_nil(min_goals) do
    goles * 100 / min_goals
  end

  def calculate_indiv_comp_single_player(_player) do
    0.0
  end

  @spec filter_maps_tuples(tuple | map) :: :error | :players
  def filter_maps_tuples(value) when is_map(value), do: :players
  def filter_maps_tuples(value) when is_tuple(value), do: :error

  @spec get_separated_players_errors(list(map()), charlist() | nil) :: map()
  def get_separated_players_errors(player_list, team_name) do
    get_min_player_goals(player_list, team_name)
    |> Enum.group_by(fn player -> filter_maps_tuples(player) end)
  end

  @spec put_indiv_comp_in_players(map()) :: list()
  def put_indiv_comp_in_players(%{players: players}) when length(players) > 0 do
    Enum.map(players, fn player ->
      s_c = calculate_indiv_comp_single_player(player)
      Map.put(player, :individual_compliance, s_c)
    end)
  end

  def put_indiv_comp_in_players(_players) do
    []
  end

  @spec get_indiv_comp_players(list(map()), charlist()) :: map()
  def get_indiv_comp_players(player_list, team_name) do
    players_goals = get_separated_players_errors(player_list, team_name)
    players_sing_comp = put_indiv_comp_in_players(players_goals)

    %{players: players_sing_comp, errors: players_goals[:error]}
  end

  @spec calculate_teams_comp(map()) :: map()
  def calculate_teams_comp(%{players: player_list, errors: errors})
      when length(player_list) > 0 do
    by_team = Enum.group_by(player_list, fn player -> player.equipo end)
    teams = Map.keys(by_team)

    team_comp =
      Enum.map(teams, fn team ->
        cur_team = Map.fetch!(by_team, team)
        TeamHelper.get_compliance_by_team(cur_team)
      end)

    %{players: team_comp, errors: errors}
  end

  def calculate_teams_comp(%{errors: errors}) do
    %{players: [], errors: errors}
  end

  @spec put_global_comp_in_players_single_player(map()) :: float()
  def put_global_comp_in_players_single_player(%{individual_compliance: sc, team_compliance: tc}) do
    (sc + tc) / 2
  end

  @spec put_global_comp_in_players(map()) :: map()
  def put_global_comp_in_players(%{players: player_list, errors: errors})
      when length(player_list) > 0 do
    global_comp =
      List.flatten(player_list)
      |> Enum.map(fn player ->
        g_c = put_global_comp_in_players_single_player(player)
        Map.put(player, :global_compliance, g_c)
      end)

    %{players: global_comp, errors: errors}
  end

  def put_global_comp_in_players(%{errors: errors}) do
    %{players: [], errors: errors}
  end

  @spec get_global_comp_for_players(list(map()), charlist()) :: map()
  def get_global_comp_for_players(player_list, team_name) do
    get_indiv_comp_players(player_list, team_name)
    |> calculate_teams_comp
    |> put_global_comp_in_players
  end

  @spec calc_full_salary_single_player(map()) :: number()
  def calc_full_salary_single_player(%{bono: bonus, sueldo: salary, global_compliance: g_c})
      when g_c == 100.0 do
    salary + bonus
  end

  def calc_full_salary_single_player(%{bono: bonus, sueldo: salary, global_compliance: g_c}) do
    salary + bonus * g_c / 100
  end

  @spec put_full_salary_in_players(map()) :: map()
  def put_full_salary_in_players(%{players: player_list, errors: errors}) when length(player_list) > 0 do
    players_salary =
      Enum.map(player_list, fn player ->
        salary = calc_full_salary_single_player(player)
        Map.put(player, :sueldo_completo, salary)
      end)

    %{players: players_salary, errors: errors}
  end

  def put_full_salary_in_players(%{errors: err}) do
    %{players: [], errors: err}
  end

  @spec take_only_necessary_attrs(list(map())) :: list(map())
  def take_only_necessary_attrs(players) when length(players) > 0 do
    Enum.map(players, fn player ->
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
    end)
  end

  @spec format_errors(list()) :: list()
  def format_errors(errors) when length(errors) > 0 do
    errors
    |> Enum.map(fn error -> %{error: elem(error, 1)} end)
  end

  def format_errors(errors), do: errors

  @spec format_output(map()) :: map()
  def format_output(%{players: player_list, errors: errors}) when length(player_list) > 0 do
    %{
      players: take_only_necessary_attrs(player_list),
      errors: format_errors(errors)
    }
  end

  def format_output(%{errors: errors}) do
    %{players: [], errors: format_errors(errors)}
  end

  @spec calculate_complete_salary_for_players(list(map()), charlist() | nil) :: list()
  def calculate_complete_salary_for_players(player_list, team_name)
      when length(player_list) > 0 do
    get_global_comp_for_players(player_list, team_name)
    |> put_full_salary_in_players
    |> format_output
  end

  def calculate_complete_salary_for_players(_player_list, _team_name) do
    [{:error, "Lista de jugadores inválida"}]
  end
end
