defmodule Resuelve.Helpers.LevelHelper do
  @moduledoc """
  This module contains all the helpers to retrieve, and save info
  to persist accross the LevelManager.
  """
  @moduledoc since: "1.0.0"

  alias Resuelve.Contexts.Level
  alias Resuelve.Contexts.LevelManager

  @doc """
  Converts a map to a Level structure
  """
  @spec level_builder(map()) :: %Level{}
  def level_builder(%{"nivel" => level, "goles_minimos" => goles_min, "equipo" => team}) do
    %Level{
      level_name: level,
      min_goals: goles_min,
      team_name: team
    }
  end

  @doc """
  Retrieve from the database the levels and teams that are already registered
  """
  @spec get_current_levels :: map()
  def get_current_levels() do
    LevelManager.get_all_levels()
    |> Enum.group_by(fn level -> level.equipo end)
  end

  @doc """
  Controls the output to the controller to display custom responses according
  the input given to create levels
  """
  @spec validate_output_create_levels(any) :: list()
  def validate_output_create_levels(input) do
    with {num, nil} <- input do
      [{:ok, true}, {:desc, %{levels_created: num}}, {:status, :ok}, {:code, 200}]
    else
      %MyXQL.Error{mysql: %{name: :ER_DUP_ENTRY}} ->
        [
          {:ok, false},
          {:desc, "Esos niveles ya existen en la BD"},
          {:status, :conflict},
          {:code, 409}
        ]

      %MyXQL.Error{mysql: %{name: :ER_BAD_NULL_ERROR}} ->
        [
          {:ok, false},
          {:desc, "Entrada inválida, se requiere el nivel, goles mínimos y nombre del equipo."},
          {:status, :bad_request},
          {:code, 400}
        ]

      %MyXQL.Error{mysql: %{name: :NOT_FOUND}} ->
        [{:ok, false}, {:desc, "Algún nive no existe."}, {:status, :bad_request}, {:code, 400}]

      err ->
        IO.inspect(err, label: "Excepción...")
        err
    end
  end

  @doc """
  Save the levels provided from the controller
  """
  @spec save_new_levels(list(map())) :: list(atom())
  def save_new_levels(levels_list) when length(levels_list) > 0 do
    Enum.map(levels_list, fn lev ->
      date = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      %{
        level_name: lev["nivel"],
        min_goals: lev["goles_minimos"],
        team_name: lev["equipo"],
        updated_at: date,
        inserted_at: date
      }
    end)
    |> LevelManager.insert_new_levels()
    |> validate_output_create_levels()
  end

  def save_new_levels(_levels_list) do
    [:error]
  end

  @doc """
  Controls the output to the controller when is trying to update levels
  """
  @spec validate_output_updates(list()) :: list()
  def validate_output_updates(results) do
    res = Enum.all?(results, fn x -> x == :ok end)

    with true <- res do
      [{:ok, true}, {:desc, "Niveles actualizados"}, {:status, :ok}, {:code, 200}]
    else
      false ->
        [
          {:ok, false},
          {:desc, "Eror al actualizar. Verifica tu entrada"},
          {:status, :bad_request},
          {:code, 400}
        ]
    end
  end

  @doc """
  Update the levels provided in the input with new minimum goals
  """
  @spec update_received_levels(list(map())) :: list(atom())
  def update_received_levels(levels_list) when length(levels_list) > 0 do
    Enum.map(levels_list, fn level ->
      LevelManager.get_level(%{name: level["nivel"], team: level["equipo"]})
      |> LevelManager.update_level(%{
        level_name: level["nivel"],
        team_name: level["equipo"],
        min_goals: level["goles_minimos"]
      })
      |> elem(0)
    end)
    |> validate_output_updates()
  end

  def update_received_levels(_levels_list) do
    [:error]
  end

  @doc """
  Controls the output to the controller when the user is trying to delete levels
  """
  @spec validate_output_delete(list()) :: list()
  def validate_output_delete(results) do
    IO.inspect(results, label: "Niveles recibidos")
    res = Enum.all?(results, fn x -> x == :ok end)

    with true <- res do
      [{:ok, true}, {:desc, "Niveles eliminados"}, {:status, :ok}, {:code, 200}]
    else
      false ->
        [
          {:ok, false},
          {:desc, "Eror al eliminar. Verifica tu entrada"},
          {:status, :bad_request},
          {:code, 400}
        ]
    end
  end

  @doc """
  Deletes the provided levels at the input if it exist
  """
  @spec delete_received_levels(list(map())) :: list()
  def delete_received_levels(levels_list) do
    Enum.map(levels_list, fn level ->
      LevelManager.get_level(%{name: level["nivel"], team: level["equipo"]})
      |> LevelManager.delete_level()
      |> elem(0)
    end)
    |> validate_output_delete()
  end
end
