defmodule Resuelve.Contexts.LevelManager do
  alias Resuelve.Level
  alias Resuelve.Repo
  # alias Resuelve.Level, as: LevelDB

  @spec get_minimum_goals_by_level(charlist(), charlist() | nil) :: tuple()
  def get_minimum_goals_by_level(level, team) when team != "" and team != nil do
    result = Repo.get_by(Level, level_name: level, team_name: team)

    with %Level{min_goals: min_goals} <- result do
      {:ok, min_goals}
    else
      _err -> {:error, "Nivel no registrado en el equipo #{team}"}
    end
  end

  def get_minimum_goals_by_level(level, _) do
    result = Repo.get_by(Level, level_name: level, team_name: "Resuelve FC")

    with %Level{min_goals: min_goals} <- result do
      {:ok, min_goals}
    else
      _err -> {:error, "Nivel no registrado"}
    end
  end
end
