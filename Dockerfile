
FROM elixir:latest

RUN apt-get update && \
    apt-get install -y inotify-tools && \
    apt-get install -y nodejs && \
    curl -L https://npmjs.org/install.sh | sh && \
    mix local.hex --force && \
    mix archive.install hex phx_new 1.5.4 --force && \
    mix local.rebar --force

RUN mkdir /app
COPY ./resuelve /app
WORKDIR /app

RUN cd /app/assets npm && \
    npm install

# Compile the project
RUN mix deps.get
RUN mix do compile
CMD ["mix", "phx.server"]