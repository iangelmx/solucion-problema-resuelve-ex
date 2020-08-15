defmodule Resuelve.Helpers.LevelHelper do
	alias Resuelve.Level, as: LevelDB
	alias Resuelve.Context.Level
	alias Resuelve.{Repo}


	@spec level_builder( map() ) :: %Level{}
	def level_builder( %{"nivel" => level ,"goles_minimos" => goles_min } ) do
		%Level{
			level: level,
			min_goals: goles_min,
		}
	end

	@spec retrieve_level_by_name( map() ) :: tuple()
	def retrieve_level_by_name( level ) when level != "" do
		level_db = Repo.get_by!(LevelDB, level: level["nivel"])
		level_to_update = %{id: level_db.id, min_goals: level["goles_minimos"], level: level["nivel"]}
		{level_db, level_to_update}
	end

	@spec get_current_levels() :: list( %Level{} )
	def get_current_levels() do
		import Ecto.Query
		query = from l in LevelDB ,select: [l.level, l.min_goals]
		Repo.all(query)
	end

	@spec save_new_levels( list( map() ) ) :: list( atom() )
	def save_new_levels( levels_list ) when length(levels_list)>0 do
		Enum.map( levels_list, fn(level) ->
			result = LevelDB.changeset( %LevelDB{}, %{level: level["nivel"], min_goals: level["goles_minimos"]} ) |> Repo.insert_or_update
			elem(result, 0)
		end)

	end
	def save_new_levels( _levels_list ) do
		[:error]
	end

	@spec update_received_levels( list( map() ) ) :: list( atom() )
	def update_received_levels( levels_list ) when length(levels_list) > 0 do
		Enum.map( levels_list, fn(level) ->
			{level_db, level_to_update} = retrieve_level_by_name( level )
			result = LevelDB.changeset( level_db, level_to_update ) |> Repo.update
			elem(result, 0)
		end)
	end
	def update_received_levels( _levels_list ) do
		[:error]
	end

	@spec delete_received_levels( list( map() ) ) :: list( atom() )
	def delete_received_levels( levels_list ) do
		Enum.map( levels_list, fn(level) ->
			level_db = Repo.get_by!(LevelDB, level: level["nivel"])
			level_to_delete = %{id: level_db.id, min_goals: level["goles_minimos"], level: level["nivel"]}
			result = LevelDB.changeset( level_db, level_to_delete ) |> Repo.update
			elem(result, 0)
		end)
	end


end
