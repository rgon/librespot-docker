# `dockercron`: cron for `docker` containers
Super simple docker container to restart other containers `CONTAINER` on a cronjob or perform other commands `COMMAND`, at the `cron` frequency specified in `CRONFREQ`.

No external dependencies used in the Dockerfile, and only the `docker` image is used, so it should be as secure as docker itself, with a reduced attack surface. It takes into consideration the [security implications](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) that other software that run [docker-from-docker](https://github.com/docker-library/docs/tree/master/docker#what-is-docker-in-docker) also have to mind.

Made as a separate container because it's easier to handle in compose/more complex deployments than a cron job in the container scripts.

-----

## Configuration
Configuration is passed through env files to the docker container. There are examples below with and without `docker-compose`.

```bash
CONTAINER=container_names to_be_restarted
-or-
COMMAND=command_to_be executed

CRONFREQ=m h dm m dw
```

You may set `$CONTAINER` to a single container name or a list of multiple space-separated container names that should be restarted. They are simply passed to `docker restart $CONTAINER`.
The `CRONFREQ` attribute contains the time and date fields from a normal [`crontab`](https://man7.org/linux/man-pages/man5/crontab.5.html).

## Usage (vanilla `docker`)
```bash
docker build -t dockercronrestarter .

# Run your container
docker run -e COMMAND="echo hello" -e CRONFREQ="* * * * *" -d dockercronrestarter
CONTAINERNAME=$(docker ps -q --filter ancestor=dockercronrestarter --format="{{.Names}}")

# Run the restarter
docker run -e CONTAINER="$CONTAINERNAME" -e CRONFREQ="* * * * *" -v /var/run/docker.sock:/var/run/docker.sock dockercronrestarter
```

On another terminal, you may run `watch -n .1 docker ps` to see the container get restarted periodically.

## Usage (`docker-compose`)
```yaml
version: '3'
services:
  # Your other services should appear here. Ensure that the service you want to restart is named the same as the CONTAINER env below, and that
  # container_name is explicitly set (not just implied by the service name) to avoid issues with docker-compose's container naming scheme.
  spotifyd:
    container_name: spotifyd
    ...
  
  restarter:
    image: dockercron
    build: 
      context: ./
      dockerfile: Dockerfile
    volumes: ["/var/run/docker.sock:/var/run/docker.sock"]
    environment:
      # Restart every day at 6:30
      - CRONFREQ=30 06 * * *
      - CONTAINER=spotifyd
    restart: unless-stopped
```