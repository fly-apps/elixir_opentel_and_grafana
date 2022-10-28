defmodule FlyOtel.Repo do
  use Ecto.Repo,
    otp_app: :fly_otel,
    adapter: Ecto.Adapters.Postgres
end
