defmodule Resuelve.Repo do
  use Ecto.Repo,
    otp_app: :resuelve,
    adapter: Ecto.Adapters.MyXQL
end
