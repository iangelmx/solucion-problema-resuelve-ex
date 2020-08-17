defmodule Resuelve.Contexts.LevelManager do
  alias Resuelve.Level
  alias Resuelve.Repo
  #alias Resuelve.Level, as: LevelDB

  def get_minimum_goals_by_level( level, team ) when team != "" and team != nil do
    result = Repo.get_by( Level, [level_name: level, team_name: team ])
    with %Level{min_goals: min_goals} <- result do
      min_goals
    end
  end
  def get_minimum_goals_by_level( level, _ ) do
    result = Repo.get_by( Level, [level_name: level, team_name: "Resuelve FC" ])
    with %Level{min_goals: min_goals} <- result do
      min_goals
    end
  end

end
