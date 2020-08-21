defmodule Resuelve.Helpers.TeamHelper do
  @moduledoc """
  This module was created to separate the operations that involve a group of players
  in a specific team and those that can be calculated with the single players
  """
  @moduledoc since: "1.0.0"

  @doc """
  Sum the scored goals of a `players_team`
  """
  @spec get_scored_goals_by_team(list(map())) :: float()
  def get_scored_goals_by_team(players_team) do
    Enum.reduce(players_team, 0, fn player, acc -> player.goles + acc end)
  end

  @doc """
  Sum the goal goals of a `players_team`
  """
  @spec get_minimum_goals_by_team(list(map())) :: float()
  def get_minimum_goals_by_team(players_team) do
    Enum.reduce(players_team, 0, fn player, acc -> player.goles_minimos + acc end)
  end

  @doc """
  Calculates the compliance of an entire team with the `scored_goals` and the
  `minimum_goals`.
  """
  @spec calculate_complicance_by_team(integer(), integer()) :: float
  def calculate_complicance_by_team(scored_goals, minimum_goals)
      when scored_goals >= minimum_goals do
    100.0
  end

  def calculate_complicance_by_team(scored_goals, minimum_goals)
      when scored_goals < minimum_goals and minimum_goals > 0 do
    scored_goals * 100 / minimum_goals
  end

  def calculate_complicance_by_team(_, _) do
    0.0
  end

  @doc """
  Calculates and puts the team compliance of a `players_team` inside them.
  Returns a players list with the `:team_compliance` key and value.
  """
  @spec get_compliance_by_team(list(map())) :: list()
  def get_compliance_by_team(players_team) do
    scored = get_scored_goals_by_team(players_team)
    minimum = get_minimum_goals_by_team(players_team)
    t_c = calculate_complicance_by_team(scored, minimum)
    Enum.map(players_team, fn player -> Map.put(player, :team_compliance, t_c) end)
  end
end
