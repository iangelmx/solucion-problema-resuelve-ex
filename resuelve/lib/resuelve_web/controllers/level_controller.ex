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
		saved = LevelHelper.save_new_levels( levels )
		json(conn, %{ok: saved, status_code: 200, description: "Updated"})
	end

	def update(conn, %{"niveles" => levels}) do

		json(conn, %{ok: "OK", status_code: 200, description: "Updated"})
	end
end
