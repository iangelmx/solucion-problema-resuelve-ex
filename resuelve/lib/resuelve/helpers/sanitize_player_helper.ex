defmodule Resuelve.Helpers.SanitizePlayerHelper do
  @moduledoc """
  This module is created to contener la mayor parte de los casos que podrían
  hacer fallar al aplicativo.
  """
  @moduledoc since: "1.0.0"

  @doc """
  Check if a `player` has the required keys values to be processed.
  Returns a list with the missing keys-values
  """
  @spec get_missing_keys_for_player(map()) :: list()
  def get_missing_keys_for_player(player) do
    ["nivel", "goles", "sueldo", "bono", "equipo"] -- Map.keys(player)
  end

  @doc """
  # Joins a items `list` and returns it as coma separated values
  """
  @spec join_list(list()) :: charlist()
  def join_list(list) when length(list) > 0 do
    Enum.join(list, ", ")
  end

  @spec check_necessary_attrs(map()) :: map()
  def check_necessary_attrs(player) do
    missing_keys = get_missing_keys_for_player(player)

    if length(missing_keys) > 0 do
      %{
        status: :error,
        info:
          "No se puede calcular el sueldo de \"#{player["nombre"]}\" si le faltan los valores de: #{
            join_list(missing_keys)
          }",
        data: player
      }
    else
      %{status: :ok, data: player}
    end
  end

  @spec get_missing_keys_in_players(list(map())) :: map()
  def get_missing_keys_in_players(raw_players) when length(raw_players) > 0 do
    raw_players
    |> Enum.map(fn player -> check_necessary_attrs(player) end)
    |> Enum.group_by(fn player -> player.status end)
  end

  @spec check_attrs_players(list(map())) :: tuple()
  def check_attrs_players(raw_players) when length(raw_players) > 0 do
    validated_req_keys = get_missing_keys_in_players(raw_players)

    if Map.has_key?(validated_req_keys, :error) == true do
      {:error, validated_req_keys[:error], validated_req_keys[:ok]}
    else
      {:ok, true, raw_players}
    end
  end

  def check_attrs_players(_raw_players) do
    {:error, [], []}
  end

  @spec valid_level(charlist()) :: tuple
  def valid_level(level) when is_bitstring(level) and not is_nil(level), do: {:ok, level}
  def valid_level(_level), do: {:error, "'nivel' debería ser una cadena de caracteres"}

  @spec valid_goals(number()) :: tuple()
  def valid_goals(goals) when goals > 0 and is_integer(goals), do: {:ok, goals}
  def valid_goals(_goals), do: {:error, "'goles' debería ser un entero positivo"}

  @spec valid_sueldo(number()) :: tuple()
  def valid_sueldo(salary) when salary > 0 and is_number(salary), do: {:ok, salary}
  def valid_sueldo(_salary), do: {:error, "'sueldo' debería ser una cifra positiva"}

  @spec valid_bonus(number()) :: tuple()
  def valid_bonus(bonus) when bonus > 0 and is_number(bonus), do: {:ok, bonus}
  def valid_bonus(_bonus), do: {:error, "'bono' debería ser una cifra positiva"}

  @spec valid_team(charlist()) :: tuple()
  def valid_team(team) when is_bitstring(team) and not is_nil(team), do: {:ok, team}
  def valid_team(_team), do: {:error, "'equipo' debería ser una cadena de caracteres"}

  # How to carry errors to valid values ELSE with?

  @spec valid_values(map()) :: map()
  def valid_values(player) do
    with {:ok, level} <- valid_level(player["nivel"]),
         {:ok, goals} <- valid_goals(player["goles"]),
         {:ok, salary} <- valid_sueldo(player["sueldo"]),
         {:ok, bonus} <- valid_bonus(player["bono"]),
         {:ok, team} <- valid_team(player["equipo"]) do
      %{
        status: "ok",
        nombre: player["nombre"],
        goles: goals,
        sueldo: salary,
        bono: bonus,
        equipo: team,
        nivel: level
      }
    else
      _err ->
        %{
          status: "failed",
          error: "El jugador #{player["nombre"]} tiene valores inválidos para calcular su sueldo"
        }
    end
  end

  @spec have_correct_values?(list(map())) :: map()
  def have_correct_values?(players_list) when length(players_list) > 0 do
    separated_players =
      Enum.map(players_list, fn player -> valid_values(player) end)
      |> Enum.group_by(fn player -> player.status end)

    %{with_errors: separated_players["failed"], correct: separated_players["ok"]}
  end

  def have_correct_values?(_players_list) do
    %{with_errors: %{info: "Entrada inválida"}, correct: []}
  end

  @doc """
  Calls to the others functions to sanitize a players list provided in the input
  Returns a map with the errors and the valid players
  """
  @spec sanitize_raw_player(list(map)) :: map()
  def sanitize_raw_player(raw_players) when length(raw_players) > 0 do
    players_with_attrs = check_attrs_players(raw_players)

    with {:ok, _, players} <- players_with_attrs do
      with %{with_errors: failed_players, correct: correct_players} <-
             have_correct_values?(players) do
        %{ok: correct_players, errors: failed_players}
      end
    else
      _err ->
        with %{with_errors: failed_players, correct: correct_players} <-
               have_correct_values?(elem(players_with_attrs, 2)) do
          %{
            ok: correct_players,
            errors: %{
              invalid_values: failed_players,
              missing_attributes: elem(players_with_attrs, 1)
            }
          }
        end
    end
  end

  def sanitize_raw_player(_) do
    %{error: "Se ha recibido una lista vacía de jugadores"}
  end
end
