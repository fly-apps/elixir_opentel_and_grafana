# Elixir, OpenTelemetry, and the Infamous N+1

This project accompanies the [Elixir, OpenTelemetry, and the Infamous N+1](https://fly.io/phoenix-files/opentelemetry-and-the-infamous-n-plus-1/) article on Fly.io's [Phoenix Files](https://fly.io/phoenix-files/) blog.

This dives into the topic of observability and specifically the [OpenTelemetry project](https://opentelemetry.io/). It uses Elixir and [Erlang OpenTelemetry](https://github.com/open-telemetry/opentelemetry-erlang) libraries in a Phoenix LiveView application and shows how to debug troublesome database queries. It also shows how the application can be deployed to [Fly.io](https://fly.io) along with [Grafana](https://grafana.com/) and
[Tempo](https://grafana.com/oss/tempo/) so we can store and query our request traces.

Please refer to [the article](https://fly.io/phoenix-files/opentelemetry-and-the-infamous-n-plus-1/) for explanation of what the different parts are and why they are used.

## FlyOtel

The root of the repo is an [Elixir](https://elixir-lang.org/) [Phoenix](https://www.phoenixframework.org/) application called `FlyOtel`. It is a [LiveView](https://github.com/phoenixframework/phoenix_live_view/) application that demonstrates an efficient and N+1 inneficient way to query the database.

## Grafana

[Grafana](https://grafana.com/) is the tool used to visualize the application request traces.

Find the files in the `fly_apps/grafana` directory. It sets up a Dockerfile image, provides minimal config and can be deployed to Fly.io.

## Tempo

[Tempo](https://grafana.com/oss/tempo/) is used to store the trace data that Grafana displays.

Find the files in `fly_apps/tempo` directory. It sets up a Dockerfile image, provides minimal config and can be deployed to Fly.io.

## Local Development/Testing

If you would like to test drive these tools on your own machine, you can use the `docker-compose.yml` in the
`local_docker` directory and spin up Grafana and Tempo along side your local running instance of the LiveView
application.
