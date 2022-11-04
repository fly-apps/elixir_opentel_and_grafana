defmodule FlyOtel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Set the correct :httpc :ipfamily flag so that the OpenTelemetry exporter
    # can ship traces to Tempo in Fly since that requires IPv6. We'll check for
    # the ECTO_IPV6 env var since the same configuration is required there when
    # the application is deployed
    if System.get_env("ECTO_IPV6") do
      :httpc.set_option(:ipfamily, :inet6fb4)
    end

    # Set up the OpenTelemetry to trace library telemetry events
    :ok = :opentelemetry_cowboy.setup()
    :ok = OpentelemetryPhoenix.setup()
    :ok = OpentelemetryLiveView.setup()

    :ok =
      FlyOtel.Repo.config()
      |> Keyword.fetch!(:telemetry_prefix)
      |> OpentelemetryEcto.setup()

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
