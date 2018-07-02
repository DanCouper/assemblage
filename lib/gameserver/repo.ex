defmodule Gameserver.Repo do
  use Ecto.Repo,
    otp_app: :gameserver,
    adapter: Ecto.Adapters.Postgres
end
