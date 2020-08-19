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

  @spec get_all_levels() :: map()
  def get_all_levels() do
    import Ecto.Query

    Repo.all(
      from l in Level,
        select: %{
          nivel: l.level_name,
          goles_minimos: l.min_goals,
          equipo: l.team_name
        },
        order_by: [asc: :team_name, asc: :level_name]
    )
  end

  @spec insert_new_levels(list(map())) :: tuple
  def insert_new_levels(niveles) do
    try do
      Repo.insert_all(Level, niveles)
    rescue
      e in MyXQL.Error -> e
    end
  end

  @spec get_level(map()) :: %Level{} | %Ecto.NoResultsError{}
  def get_level(%{name: level, team: team}) do
    try do
      Repo.get_by!(Level, level_name: level, team_name: team)
    rescue
      e in Ecto.NoResultsError -> e
    end
  end

  @spec update_level(%Level{} | %Ecto.NoResultsError{}, map()) :: tuple()
  def update_level(level_db, level_to_update) do
    with level = %Level{} <- level_db do
      Level.changeset(level, level_to_update) |> Repo.update()
    else
      %Ecto.NoResultsError{} -> {:error, "Nivel inexistente"}
    end
  end

  @spec delete_level(%Level{}) :: tuple
  def delete_level(level_db) do
    with level = %Level{} <- level_db do
      case Repo.delete(level) do
        {:ok, _struct} -> {:ok, "Eliminado"}
        {:error, _changeset} -> {:error, "Error al eliminar"}
      end
    else
      %Ecto.NoResultsError{} -> {:error, "Nivel inexistente"}
    end
  end
end
