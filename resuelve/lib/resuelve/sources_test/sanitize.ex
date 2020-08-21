defmodule Resuelve.SourcesTest.Sanitize do
  def get_input_check_attrs_player_1() do
    [
      %{
        "nombre" => "6af19",
        "nivel" => "B",
        "bono" => 878.4910,
        "equipo" => 68_519_898,
        "sueldo" => 681_987_987,
        "goles" => 56
      },
      %{
        "nombre" => 8_519_898,
        "nivel" => "!af3",
        "bono" => "a33fsdf",
        "equipo" => "a81"
      },
      %{
        "nombre" => "81987f9719",
        "nivel" => "6a1f9es8f",
        "bono" => "asfde391",
        "equipo" => "981",
        "sueldo" => "af3 ro2i3m wa",
        "goles" => "6as1f9a81e98a1e9f8ae8f19"
      }
    ]
  end

  def get_output_check_attrs_player_1() do
    e_0 = %{
      "nombre" => "6af19",
      "nivel" => "B",
      "bono" => 878.4910,
      "equipo" => 68_519_898,
      "sueldo" => 681_987_987,
      "goles" => 56
    }

    e_1 = %{
      "nombre" => 8_519_898,
      "nivel" => "!af3",
      "bono" => "a33fsdf",
      "equipo" => "a81"
    }

    e_2 = %{
      "nombre" => "81987f9719",
      "nivel" => "6a1f9es8f",
      "bono" => "asfde391",
      "equipo" => "981",
      "sueldo" => "af3 ro2i3m wa",
      "goles" => "6as1f9a81e98a1e9f8ae8f19"
    }

    {:error,
     [
       %{
         status: :error,
         info:
           "No se puede calcular el sueldo de \"8519898\" si le faltan los valores de: goles, sueldo",
         data: e_1
       }
     ], [%{status: :ok, data: e_0}, %{status: :ok, data: e_2}]}
  end

  def get_input_check_attrs_player_2() do
    [
      %{
        "nombre" => "6af19",
        "nivel" => "B",
        "bono" => 878.4910,
        "equipo" => 68_519_898,
        "sueldo" => 681_987_987,
        "goles" => 56
      },
      %{
        "nombre" => 8_519_898,
        "nivel" => "!af3",
        "bono" => "a33fsdf",
        "equipo" => "a81",
        "sueldo" => 681_987_987,
        "goles" => 56
      },
      %{
        "nombre" => "81987f9719",
        "nivel" => "6a1f9es8f",
        "bono" => "asfde391",
        "equipo" => "981",
        "sueldo" => "af3 ro2i3m wa",
        "goles" => "6as1f9a81e98a1e9f8ae8f19"
      }
    ]
  end

  def get_output_check_attrs_player_2() do
    e_0 = %{
      "nombre" => "6af19",
      "nivel" => "B",
      "bono" => 878.4910,
      "equipo" => 68_519_898,
      "sueldo" => 681_987_987,
      "goles" => 56
    }

    e_1 = %{
      "nombre" => 8_519_898,
      "nivel" => "!af3",
      "bono" => "a33fsdf",
      "equipo" => "a81",
      "sueldo" => 681_987_987,
      "goles" => 56
    }

    e_2 = %{
      "nombre" => "81987f9719",
      "nivel" => "6a1f9es8f",
      "bono" => "asfde391",
      "equipo" => "981",
      "sueldo" => "af3 ro2i3m wa",
      "goles" => "6as1f9a81e98a1e9f8ae8f19"
    }

    {:ok, true, [e_0, e_1, e_2]}
  end

  @spec get_input_have_correct_values_1? :: [
          %{optional(<<_::32, _::_*8>>) => nil | <<_::8, _::_*8>> | number},
          ...
        ]
  def get_input_have_correct_values_1?() do
    [
      %{
        "nombre" => "6af19",
        "nivel" => "B",
        "bono" => 878.4910,
        "equipo" => 68_519_898,
        "sueldo" => 96_541_981,
        "goles" => 56
      },
      %{
        "nombre" => "8319f1af9",
        "nivel" => 159,
        "bono" => 878.4910,
        "equipo" => nil,
        "sueldo" => 96_541_981,
        "goles" => 56
      },
      %{
        "nivel" => "Abc",
        "bono" => 878.4910,
        "equipo" => "Rojo",
        "sueldo" => 96_541_981,
        "goles" => 56
      }
    ]
  end

  def get_output_have_correct_values_1? do
    %{
      with_errors: [
        %{
          status: "failed",
          error: "El jugador 6af19 tiene valores inválidos para calcular su sueldo"
        },
        %{
          status: "failed",
          error: "El jugador 8319f1af9 tiene valores inválidos para calcular su sueldo"
        }
      ],
      correct: [
        %{
          status: "ok",
          nombre: nil,
          goles: 56,
          sueldo: 96_541_981,
          bono: 878.4910,
          equipo: "Rojo",
          nivel: "Abc"
        }
      ]
    }
  end

  def get_input_have_correct_values_2?() do
    [
      %{
        "nombre" => "6af19",
        "nivel" => "B",
        "bono" => 878.4910,
        "equipo" => nil,
        "sueldo" => -591,
        "goles" => 56
      },
      %{
        "nombre" => "8319f1af9",
        "nivel" => 159,
        "bono" => -878.4910,
        "equipo" => nil,
        "sueldo" => "96541981",
        "goles" => 56
      },
      %{
        "nivel" => "Abc",
        "bono" => 878.4910,
        "equipo" => "Rojo",
        "sueldo" => nil,
        "goles" => 56
      }
    ]
  end

  def get_output_have_correct_values_2? do
    %{
      with_errors: [
        %{
          status: "failed",
          error: "El jugador 6af19 tiene valores inválidos para calcular su sueldo"
        },
        %{
          status: "failed",
          error: "El jugador 8319f1af9 tiene valores inválidos para calcular su sueldo"
        },
        %{
          status: "failed",
          error: "El jugador  tiene valores inválidos para calcular su sueldo"
        }
      ],
      correct: nil
    }
  end

  def get_input_have_correct_values_3?() do
    [
      %{
        "nombre" => "6af19",
        "nivel" => "B",
        "bono" => 878.4910,
        "equipo" => "FA3J FOAI398F3 EDFAW",
        "sueldo" => 96_541_981,
        "goles" => 56
      },
      %{
        "nombre" => "8319f1af9",
        "nivel" => "Cuauh",
        "bono" => 878.4910,
        "equipo" => "FA3J FOAI398F3 EDFAW",
        "sueldo" => 96_541_981,
        "goles" => 56
      },
      %{
        "nivel" => "Abc",
        "bono" => 878.4910,
        "equipo" => "Rojo",
        "sueldo" => 96_541_981,
        "goles" => 56,
        "edad" => 23
      }
    ]
  end

  def get_output_have_correct_values_3? do
    %{
      with_errors: nil,
      correct: [
        %{
          status: "ok",
          nombre: "6af19",
          nivel: "B",
          bono: 878.4910,
          equipo: "FA3J FOAI398F3 EDFAW",
          sueldo: 96_541_981,
          goles: 56
        },
        %{
          status: "ok",
          nombre: "8319f1af9",
          nivel: "Cuauh",
          bono: 878.4910,
          equipo: "FA3J FOAI398F3 EDFAW",
          sueldo: 96_541_981,
          goles: 56
        },
        %{
          status: "ok",
          nombre: nil,
          goles: 56,
          sueldo: 96_541_981,
          bono: 878.4910,
          equipo: "Rojo",
          nivel: "Abc"
        }
      ]
    }
  end
end
