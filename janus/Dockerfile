# Build stage
FROM elixir:1.16-otp-25-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy configuration files
COPY mix.exs mix.lock ./
COPY config config

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy application code
COPY lib lib
COPY priv priv

# Compile and build release
ENV MIX_ENV=prod
RUN mix compile && \
    mix release

# Production stage
FROM debian:bullseye-slim AS app

# Install runtime dependencies
RUN apt-get update && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Copy release from build stage
COPY --from=builder /app/_build/prod/rel/janus ./

# Set environment variables
ENV HOME=/app
ENV PORT=4000

# Run as non-root user for better security
RUN useradd --create-home elixir
USER elixir

# Expose port
EXPOSE 4000

# Start Phoenix app
CMD ["bin/janus", "start"]
