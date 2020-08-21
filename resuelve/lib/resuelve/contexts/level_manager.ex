defmodule Resuelve.Contexts.LevelManager do
  @moduledoc """
  This module is the responsible to manage the storage of the levels in the
  database.
  """
  @moduledoc since: "1.0.0"

  alias Resuelve.Level
  alias Resuelve.Repo
  # alias Resuelve.Level, as: LevelDB

  @doc """
  Query to the database what is the minimum goals of a `level` in a certain
  `level`. When the `team` is not present or is nil, it asumes that is a Resuelve FC
  level.
  """
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

  @doc """
  Returns all the teams and levels that are registered on the database
  """
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

  @doc """
  Inserts in to the database a new level if it does not exists.
  Returns a tuple when its posible to save. Otherwise an exception.
  """
  @spec insert_new_levels(list(map())) :: tuple
  def insert_new_levels(niveles) do
    try do
      Repo.insert_all(Level, niveles)
    rescue
      e in MyXQL.Error -> e
    end
  end

  @doc """
  Returns a `%Level{}` by its name and its team name when it exists in the database
  Other wise, returns an exception
  """
  @spec get_level(map()) :: %Level{} | %Ecto.NoResultsError{}
  def get_level(%{name: level, team: team}) do
    try do
      Repo.get_by!(Level, level_name: level, team_name: team)
    rescue
      e in Ecto.NoResultsError -> e
    end
  end

  @doc """
  Updates a level if it is already registered.
  Returns a tuple with the :ok or :error atom indicating the status of the update.
  """
  @spec update_level(%Level{} | %Ecto.NoResultsError{}, map()) :: tuple()
  def update_level(level_db, level_to_update) do
    with level = %Level{} <- level_db do
      Level.changeset(level, level_to_update) |> Repo.update()
    else
      %Ecto.NoResultsError{} -> {:error, "Nivel inexistente"}
    end
  end

  @doc """
  Deletes a level from the database if it is already registered
  Returns a tuple with the :ok or :error atom indicating the status of the deletion.
  """
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
