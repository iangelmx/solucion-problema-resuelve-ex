defmodule Resuelve.Helpers.TeamHelper do

  def get_scored_goals_by_team( players_team ) do
    Enum.reduce( players_team, 0, fn player, acc -> player.goles + acc end )
  end
  def get_minimum_goals_by_team( players_team ) do
    Enum.reduce( players_team, 0, fn player, acc -> player.min_goals + acc end )
  end

  def calculate_compliance_by_team( players_team ) do
    scored_goals = get_scored_goals_by_team( players_team )
  end

end
