defmodule FlyOtel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FlyOtel.Repo,
      # Start the Telemetry supervisor
      FlyOtelWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FlyOtel.PubSub},
      # Start the Endpoint (http/https)
      FlyOtelWeb.Endpoint
      # Start a worker by calling: FlyOtel.Worker.start_link(arg)
      # {FlyOtel.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlyOtel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlyOtelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
