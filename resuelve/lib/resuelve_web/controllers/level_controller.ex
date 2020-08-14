defmodule ResuelveWeb.LevelController do
	alias Resuelve.Helpers.LevelHelper
  use ResuelveWeb, :controller
  #Patern matching
	#Documentación -> Spec's
	#Add with struct
	# Test only helpers
	@spec index( map(), map()  ) :: map()
  def index(conn, _params) do
    levels = LevelHelper.get_current_levels()
		json(conn, %{ok: true, status_code: 200, levels: levels})
	end

	def create(conn, %{"niveles" => levels }) do
		raw_levels = Enum.map( levels , fn(level) ->
				IO.inspect(level, label: "Level received")
				LevelHelper.level_builder( level )
		end )

		new = LevelHelper.save_new_levels( raw_levels )

		json(conn, %{ok: true, status_code: 200, levels: new})

	end
end
