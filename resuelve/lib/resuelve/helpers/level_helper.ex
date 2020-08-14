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

	@spec get_current_levels() :: list( %Level{} )
	def get_current_levels() do
		import Ecto.Query
		query = from l in Level ,select: [l.level, l.min_goals]
		Repo.all(query)
	end

	def save_new_levels( level_lists ) when length(level_lists)>0 do
		import Ecto.Query
		Enum.each( level_lists, fn(level) ->
			LevelDB.changeset(level) |> Repo.insert_or_update
		end)
	end


end
