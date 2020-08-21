defmodule Resuelve.Helpers.PlayerHelper do
  @moduledoc """
  This module contains all the helper functions to control and calculate
  the salary of the players
  """
  @moduledoc since: "1.0.0"

  alias Resuelve.Contexts.LevelManager
  alias Resuelve.Helpers.TeamHelper

  @doc """
  Put from de database the minimum goals of a players list.
  Return a `list` with the `maps` with attribute :goles_minimos when there are the requested level
  Otherwise, return a list with maps and `tuples` with errors
  """
  @spec put_n_get_min_player_goals(list(map()), charlist() | nil) :: list(map())
  def put_n_get_min_player_goals(player_list, team_name) do
    Enum.map(player_list, fn player ->
      with {:ok, min_goals} <- LevelManager.get_minimum_goals_by_level(player.nivel, team_name) do
        Map.put(player, :goles_minimos, min_goals)
      else
        {:error, error} -> {:error, error <> " para jugador #{player[:nombre]}"}
      end
    end)
  end

  @doc """
  Calculate the individual compliance of a player according his scored and minimum required goals
  """
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

  @doc """
  Points out if the `value` is an :players when it is a map or
  :error when `value` is a tuple
  """
  @spec filter_maps_tuples(tuple | map) :: :error | :players
  def filter_maps_tuples(value) when is_map(value), do: :players
  def filter_maps_tuples(value) when is_tuple(value), do: :error

  @doc """
  Gets the minimum required goals of a `players_list` and returns it grouped by
  valid players and errors found
  """
  @spec get_separated_players_errors(list(map()), charlist() | nil) :: map()
  def get_separated_players_errors(players_list, team_name) do
    put_n_get_min_player_goals(players_list, team_name)
    |> Enum.group_by(fn player -> filter_maps_tuples(player) end)
  end

  @doc """
  Puts the individual compliance of a `players` list and returns it modified with the key
  :individual_compliance inside of the `players` list
  Receives a map with the players list inside the :players key
  When the players list is emtpy, returns an empty list
  """
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

  @doc """
  Gets the individual compliance of the provided `players_list` and returns it in a
  map separating the valid players and the errors found
  """
  @spec get_indiv_comp_players(list(map()), charlist()) :: map()
  def get_indiv_comp_players(players_list, team_name) do
    players_goals = get_separated_players_errors(players_list, team_name)
    players_sing_comp = put_indiv_comp_in_players(players_goals)

    %{players: players_sing_comp, errors: players_goals[:error]}
  end

  @doc """
  Calculates the team compliance of a `players_list` and puts it inside of the players
  Returns a map with the values procesed and the errors found in a map
  """
  @spec calculate_teams_comp(map()) :: map()
  def calculate_teams_comp(%{players: players_list, errors: errors})
      when length(players_list) > 0 do
    by_team = Enum.group_by(players_list, fn player -> player.equipo end)
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

  @doc """
  Calculates the global compliance of a single player according the `:team_compliance` and the
  `individual_compliance`
  """
  @spec calc_global_comp_single_player(map()) :: float()
  def calc_global_comp_single_player(%{individual_compliance: sc, team_compliance: tc}) do
    (sc + tc) / 2
  end

  @doc """
  Puts the global compliance inside of a each player in players list provided.
  Returns the players with the :global_compliance inside and the errors
  """
  @spec put_global_comp_in_players(map()) :: map()
  def put_global_comp_in_players(%{players: player_list, errors: errors})
      when length(player_list) > 0 do
    global_comp =
      List.flatten(player_list)
      |> Enum.map(fn player ->
        g_c = calc_global_comp_single_player(player)
        Map.put(player, :global_compliance, g_c)
      end)

    %{players: global_comp, errors: errors}
  end

  def put_global_comp_in_players(%{errors: errors}) do
    %{players: [], errors: errors}
  end

  @doc """
  Get the players with the global compliance calculated inside them
  """
  @spec get_global_comp_for_players(list(map()), charlist()) :: map()
  def get_global_comp_for_players(player_list, team_name) do
    get_indiv_comp_players(player_list, team_name)
    |> calculate_teams_comp
    |> put_global_comp_in_players
  end

  @doc """
  Calculates the full salary of a single player according his bonus, salary and global compliance
  """
  @spec calc_full_salary_single_player(map()) :: number()
  def calc_full_salary_single_player(%{bono: bonus, sueldo: salary, global_compliance: g_c})
      when g_c == 100.0 do
    salary + bonus
  end

  def calc_full_salary_single_player(%{bono: bonus, sueldo: salary, global_compliance: g_c}) do
    salary + bonus * g_c / 100
  end

  @doc """
  Puts the full salary inside of each player provided in players list and return it
  inside of a map with the players and errors
  """
  @spec put_full_salary_in_players(map()) :: map()
  def put_full_salary_in_players(%{players: players_list, errors: errors})
      when length(players_list) > 0 do
    players_salary =
      Enum.map(players_list, fn player ->
        salary = calc_full_salary_single_player(player)
        Map.put(player, :sueldo_completo, salary)
      end)

    %{players: players_salary, errors: errors}
  end

  def put_full_salary_in_players(%{errors: err}) do
    %{players: [], errors: err}
  end

  @doc """
  Take only the required attrs to the output of the `players` list provided
  """
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

  @doc """
  Format the errors found to the output
  """
  @spec format_errors(list()) :: list()
  def format_errors(errors) when length(errors) > 0 do
    errors
    |> Enum.map(fn error -> %{error: elem(error, 1)} end)
  end

  def format_errors(errors), do: errors

  @doc """
  Format the output to return the processed players and the errors found
  """
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

  @doc """
  Calculates de complete salary of a `players_list` provided and returns the list modified with
  the :sueldo_completo key and its value of each player
  Returns a map when the processed players and the errors found
  """
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
