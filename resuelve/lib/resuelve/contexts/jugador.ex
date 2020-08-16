defmodule Resuelve.Context.Jugador do
  defstruct nombre: "",
            nivel: "",
            goles: 0,
            sueldo: 0,
            bono: 0,
            sueldo_completo: nil,
            equipo: "",
            goles_minimos: nil,
            alcance_ind: nil,
            alcance_team: nil,
            failed: false
end
