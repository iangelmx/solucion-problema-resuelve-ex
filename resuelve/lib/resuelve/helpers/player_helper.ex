defmodule Resuelve.Helpers.PlayerHelper do


  @spec get_missing_keys_for_player( map() ) :: list()
  def get_missing_keys_for_player( player ) do
    ["nivel", "goles", "sueldo", "bono", "equipo"] -- Map.keys(player)
  end

  @spec join_list( list() ) :: charlist()
  def join_list( list ) when length(list)>0 do
    Enum.join(list, ", ")
  end

  @spec check_necessary_attrs( map() ) :: map()
  def check_necessary_attrs( player ) do
    missing_keys = get_missing_keys_for_player( player )
    if length(missing_keys) > 0 do
      %{status: :error , info: "No se puede calcular el sueldo de \"#{player["nombre"]}\" si le faltan los valores de: #{join_list(missing_keys)}", data: player}
    else
      %{status: :ok, data: player}
    end
  end

  @spec get_missing_keys_in_players( list( map() )) :: list()
  def get_missing_keys_in_players( raw_players ) when length(raw_players)>0 do
    raw_players
    |> Enum.map( fn player -> check_necessary_attrs(player) end )
    |> Enum.filter( fn(player) -> player.status == :error end )
  end

  def quit_error_players( complete_list, bad_formated_players ) do
    complete_list -- Enum.map( bad_formated_players, fn player -> player.data end )
  end

  @spec sanitize_raw_player( list( map() )) :: tuple()
  def sanitize_raw_player( raw_players ) do
    with_problems = get_missing_keys_in_players( raw_players )
    if length(with_problems) > 0 do
      {:error, with_problems, :accepted, quit_error_players( raw_players, with_problems )}
    else
      {:ok, raw_players}
    end
  end

end
