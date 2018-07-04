defmodule Assemblage.Repo do
  use Ecto.Repo,
    otp_app: :assemblage,
    adapter: Ecto.Adapters.Postgres
end
