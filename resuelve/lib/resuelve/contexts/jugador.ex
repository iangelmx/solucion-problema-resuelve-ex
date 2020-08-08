defmodule Resuelve.Context.Jugador do
  defstruct [
    id: nil,
    nombre: "",
    nivel: "",
    goles: 0,
    sueldo: 0,
    bono: 0,
    sueldo_completo: nil,
    equipo: "",
    goles_min: nil,
    alcance_ind: nil,
    alcance_team: nil

  ]
end
