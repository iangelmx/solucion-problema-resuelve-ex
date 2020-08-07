# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Resuelve.Repo.insert!(%Resuelve.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Resuelve.{Repo, Level}

Repo.insert!( %Level{level: "A", min_goals: 5} )
Repo.insert!( %Level{level: "B", min_goals: 10} )
Repo.insert!( %Level{level: "C", min_goals: 15} )
Repo.insert!( %Level{level: "Cuauh", min_goals: 20} )
