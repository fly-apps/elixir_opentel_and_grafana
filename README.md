# FlyOtel

```session
$ OTEL_RESOURCE_ATTRIBUTES=service.name=fly_otel iex -S mix phx.server
```

Fixing IPv6 resolution manually:

```session
:httpc.set_option(:ipfamily, :inet6)

:httpc.get_option(:ipfamily)
```

# ---- Article contents ----

# Elixir, OpenTelemetry, and the Infamous N+1

## Introduction

In this article, I'll be diving into the topic of observability and specifically the OpenTelemetry project. You'll see
how you can set up the Elixir and Erlang OpenTelemetry libraries in a Phoenix LiveView application so that you can debug
some troublesome database queries. You'll also see how this application can be deployed to Fly.io along with Grafana and
Tempo so that you can store and query your sample traces. Before diving into the nitty-gritty, let's first get a sense
for the application observability landscape.

As a software engineer, it is crucial that you have insight into your running applications. This is especially true if
you have customers paying-for and depending-on your products. As a customer and user, there are few things more
frustrating that trying to get your work done and some SaaS product that you pay for is currently unavailable or running
extremely slow. As a business, you may be able to get away with some down-time and slow services here and there, but if
it becomes the norm, your customer-experience will deteriorate to the point where your customers start looking else
where.

But don't worry - it's not all doom and gloom! As software engineers, there are plenty of tools at our disposal that
enable us to provide the best customer experience possible. For example, as you are developing a piece of software you
can write unit, integration, end-to-end and stress tests to ensure that features are implemented properly and that they
continue to work tomorrow even though the codebase is constantly changing. These tools work great for local development
and CI/CD...but what do you do when your application is running in production and you are encountering issues? To answer
that question, we'll need to reach for tools that fall under the observability umbrella.

## The Three Pillars of Observability

Observability in the context of software is the ability to inspect and understand a running application. In order to
introspect your application you will need to extract some data from it as it is running without hindering its ability to
service user requests. Observability tooling that interferes with an application's natural ability to service requests
is not viable in production as it will be impacting your customers in undefined ways. So how we extract data from a
running application in such a way? The three most common ways to achieve this goal are logging, metrics and traces.
Combined they create the three pillars of observability and allow you to effectively analyze and debug your production
applications and systems. Let's briefly look at what each of these pillars does for us to get a sense for how they work
together to give us application observability:

- Logs: Logs contain detailed information as to what events are taking place within an application. Logs can be either
  structured (JSON for example) or unstructured (free text).

- Metrics: Metrics are measurements of your application over time and can contain a few bits of metadata to enrich the
  measurements and to give them more context.

- Traces: Traces are a collection of related events with each event containing metadata as to what happened and for how
  long. Traces can span across call stacks on a single machine and even across services via distributed tracing.

In this article, we'll be focusing on the tracing observability pillar. Specifically, we will see how we can leverage
the OpenTelemetry tracing tooling to identify performance issues in an Elixir Phoenix LiveView application. Let's dive
into what OpenTelemetry is and how we can set it up in our LiveView application.

## Configuring OpenTelemetry in Elixir

OpenTelemetry (often abbreviated to OTel), is a collection of open source standards for how logs, metrics, and traces
should be collected and exported from services. By design, it is a programming language agnostic standard and there are
implementations of the [OTel standard in a lot of programming
languages](https://opentelemetry.io/docs/getting-started/dev/) already including Erlang and Elixir!

At a high level, the [OTel standard specifies a few different
components](https://opentelemetry.io/docs/concepts/components/) that need to be available in order to ship logs, metrics
and traces from your applications. The API and SDK components are what you are leaning on when you instrument your
application with the tracing library for Ecto for example. The collector component, is what that Ecto tracing library
will ship telemetry data to, which will then in turn export that telemetry data to Jaeger, Tempo, or whatever you are
using to persist sample traces.

Luckily, instrumenting your Elixir applications isn't too hard thanks to all of the hard work done by the contributors
to the [Hex OpenTelemetry organization](https://hex.pm/orgs/opentelemetry). For this article, I put together a sample
TODO list LiveView application that has two routes of interest. `/users-fast` and `/users-slow` both list all of the
users of the application and also list how many TODO list items each of them have in their queue. As the names of the
routes imply, one of the routes responds quickly, and the other not so much. The question that we need to answer is why
is this occurring and how we can remedy the problem. If you noticed the title of the article you may have an idea as to
why the endpoint is slow...but it'll really be clear once you look at a trace from the application when the
`/users-slow` route is called.

All the code of the sample application can be found [here](NEED PUBLIC GIT_HUB) but let's start by going through the
application specific changes that we need to make in order to instrument our application. First we'll open up `mix.exs`
and add the following dependencies:

```elixir
defp deps do
  [
    ...
    {:opentelemetry_exporter, "~> 1.0"},
    {:opentelemetry, "~> 1.0"},
    {:opentelemetry_api, "~> 1.0"},
    {:opentelemetry_ecto, "~> 1.0"},
    {:opentelemetry_liveview, "~> 1.0.0-rc.4"},
    {:opentelemetry_phoenix, "~> 1.0"},
    {:opentelemetry_cowboy, "~> 0.2"}
  ]
end
```

After doing that we can run `mix deps.get` in order to fetch the dependencies from Hex. Next, you'll want to open up the
`application.ex` file and update the `start/1` callback as follows:

```elixir
def start(_type, _args) do
  :ok = :opentelemetry_cowboy.setup()
  :ok = OpentelemetryPhoenix.setup()
  :ok = OpentelemetryLiveView.setup()

  :ok =
    FlyOtel.Repo.config()
    |> Keyword.fetch!(:telemetry_prefix)
    |> OpentelemetryEcto.setup()

  ...
end
```

The first three `setup/0` calls set up the Cowboy, Phoenix, and LiveView tracing libraries. These calls, instruct the
OTel libraries to attach handlers to the telemetry events that are emitted by each of the underlying libraries. The
Ecto tracing library requires a little more work to set up as we need to fetch the configured telemetry prefix so that
the OTel library can attach the handler to the correct Repo event. With that in place, all that needs to be done now is
to update some configuration in `runtime.exs` in order for the telemetry exporter to know where to send trace data. Add
the following inside of the `config_env() == :prod` if-block:

```elixir
config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_endpoint: System.fetch_env!("TEMPO_URL")
```

With this in place, we are able to configure our application at runtime so that it is able to send traces to the correct
service. In in this example we will be leaning on Tempo to capture and persist traces. Once the traces are in Tempo, we
can then use Grafana to explore the persisted traces and see why our endpoints differ in performance.

As you can see, there is not a lot of ceremony or effort on our part in order to start collecting traces from our
application. Next, let's see how we can deploy our application and all of its dependencies to Fly.io so we can capture
and view some real traces.

## Deploying and Observing Your Application on Fly.io

Let's being by installing the `flyctl` CLI utility and authenticating with fly.io so we can start deploying our services
using the following guide: https://fly.io/docs/hands-on/install-flyctl/.

After you have done that, we are ready to start deploying all of the necessary services including our trace enabled
Phoenix LiveView application. Let's begin by deploying Tempo which will store all of the traces that our collector
exports.

### Tempo

In order to run Tempo in fly.io, we'll need to create our own Docker container that

### Grafana

### Phoenix App + Postgres
