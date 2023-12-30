# [thespad/traefik-crowdsec-bouncer](https://github.com/thespad/docker-traefik-crowdsec-bouncer)

[![GitHub Release](https://img.shields.io/github/release/thespad/docker-traefik-crowdsec-bouncer.svg?color=26689A&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/thespad/docker-traefik-crowdsec-bouncer/releases)
![Commits](https://img.shields.io/github/commits-since/thespad/docker-traefik-crowdsec-bouncer/latest?color=26689A&include_prereleases&logo=github&style=for-the-badge)
![Image Size](https://img.shields.io/docker/image-size/thespad/traefik-crowdsec-bouncer/latest?color=26689A&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=Size)
[![Docker Pulls](https://img.shields.io/docker/pulls/thespad/traefik-crowdsec-bouncer.svg?color=26689A&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/thespad/traefik-crowdsec-bouncer)
[![GitHub Stars](https://img.shields.io/github/stars/thespad/docker-traefik-crowdsec-bouncer.svg?color=26689A&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/thespad/docker-traefik-crowdsec-bouncer)
[![Docker Stars](https://img.shields.io/docker/stars/thespad/traefik-crowdsec-bouncer.svg?color=26689A&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=stars&logo=docker)](https://hub.docker.com/r/thespad/traefik-crowdsec-bouncer)

[![ci](https://img.shields.io/github/actions/workflow/status/thespad/docker-traefik-crowdsec-bouncer/call-check-and-release.yml?branch=main&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github&label=Check%20For%20Upstream%20Updates)](https://github.com/thespad/docker-traefik-crowdsec-bouncer/actions/workflows/call-check-and-release.yml)
[![ci](https://img.shields.io/github/actions/workflow/status/thespad/docker-traefik-crowdsec-bouncer/call-baseimage-update.yml?branch=main&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github&label=Check%20For%20Baseimage%20Updates)](https://github.com/thespad/docker-traefik-crowdsec-bouncer/actions/workflows/call-baseimage-update.yml)
[![ci](https://img.shields.io/github/actions/workflow/status/thespad/docker-traefik-crowdsec-bouncer/call-build-image.yml?labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github&label=Build%20Image)](https://github.com/thespad/docker-traefik-crowdsec-bouncer/actions/workflows/call-build-image.yml)

[traefik-crowdsec-bouncer](https://github.com/thespad/traefik-crowdsec-bouncer/) is an HTTP service to verify requests and bounce them according to decisions made by CrowdSec. Fork of [https://github.com/fbonalair/traefik-crowdsec-bouncer](https://github.com/fbonalair/traefik-crowdsec-bouncer) with extra features.

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`.

Simply pulling `ghcr.io/thespad/traefik-crowdsec-bouncer` should retrieve the correct image for your arch.

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | latest |
| arm64 | ✅ | latest |

## Application Setup

1. Get a bouncer API key from CrowdSec with command `docker exec -t crowdsec cscli bouncers add bouncer-traefik`
2. Copy the API key printed. You **_WON'T_** be able the get it again.
3. Paste this API key as the value for bouncer environment variable `CROWDSEC_BOUNCER_API_KEY`, or use an `.env` file.
4. Set the other environment variables as required (see below for details).
5. Start bouncer.
6. Visit a site proxied by Traefik and confirm you can access it.
7. In another console, ban your IP with command `docker exec crowdsec cscli decisions add --ip <your ip> -R "Test Ban"`, modify the IP with your address.
8. Visit the site again, in your browser you will see "Forbidden" since this time since you've been banned.
9. Unban yourself with `docker exec crowdsec cscli decisions delete --ip <your IP>`
10. Visit the site one last time, you will have access to the site again.

### Traefik Setup

Create a Forward Auth middleware, i.e.

```yml
    middleware-crowdsec-bouncer:
      forwardauth:
        address: http://traefik-crowdsec-bouncer:8080/api/v1/forwardAuth
        trustForwardHeader: true
```

Then apply it either to individual containers you wish to protect or as a default middlware on the Traefik listener.

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose ([recommended](https://docs.linuxserver.io/general/docker-compose))

Compatible with docker-compose v2 schemas.

```yaml
---
version: "2.1"
services:
  traefik-crowdsec-bouncer:
    image: ghcr.io/thespad/traefik-crowdsec-bouncer
    container_name: traefik-crowdsec-bouncer
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - CROWDSEC_BOUNCER_API_KEY=${TRAEFIK_BOUNCER_KEY}
      - CROWDSEC_AGENT_HOST=crowdsec:8080
      - CROWDSEC_BOUNCER_SCHEME=http #Optional
      - TRUSTED_PROXIES=0.0.0.0/0 #Optional
      - PORT=8080 #Optional
      - CROWDSEC_BOUNCER_LOG_LEVEL=1 #Optional
      - GIN_MODE=release #Optional
      - CROWDSEC_BOUNCER_SKIPRFC1918=true #Optional
      - CROWDSEC_BOUNCER_REDIRECT= #Optional
      - CROWDSEC_BOUNCER_CLOUDFLARE=false #Optional
    ports:
      - 8080:8080
    restart: unless-stopped
```

### docker cli

```shell
docker run -d \
  --name=traefik-crowdsec-bouncer \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZEurope/London \
  -e CROWDSEC_BOUNCER_API_KEY=${TRAEFIK_BOUNCER_KEY} \
  -e CROWDSEC_AGENT_HOST=crowdsec:8080 \
  -e CROWDSEC_BOUNCER_SCHEME=http `#optional` \
  -e TRUSTED_PROXIES=0.0.0.0/0 `#optional` \
  -e PORT=8080 `#optional` \
  -e CROWDSEC_BOUNCER_LOG_LEVEL=1 `#optional` \
  -e GIN_MODE=release `#optional` \
  -e CROWDSEC_BOUNCER_SKIPRFC1918=true `#optional` \
  -e CROWDSEC_BOUNCER_REDIRECT= `#optional` \
  -e CROWDSEC_BOUNCER_CLOUDFLARE=false `#optional` \
  -p 8080:8080 \
  --restart unless-stopped \
  ghcr.io/thespad/traefik-crowdsec-bouncer
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 1935` | Web GUI |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG America/New_York |
| `-e CROWDSEC_BOUNCER_API_KEY=` | CrowdSec bouncer API key (required). |
| `-e CROWDSEC_AGENT_HOST=` | Host and port of CrowdSec LAPI agent, i.e. crowdsec-agent:8080 (required). |
| `-e CROWDSEC_BOUNCER_SCHEME=` | Scheme to query CrowdSec agent. Allowed values: `http`, `https`. Default is `http`. |
| `-e TRUSTED_PROXIES=` | IP addresses of upstream proxies. Can accept a list of IP addresses in CIDR format, delimited by ','. Default is `0.0.0.0/0`. |
| `-e PORT=` | Change listening port of web server. Default is `8080`. |
| `-e CROWDSEC_BOUNCER_LOG_LEVEL=` | Minimum log level for bouncer. Allowed values: [zerolog levels](https://pkg.go.dev/github.com/rs/zerolog#readme-leveled-logging). Default is `1`. |
| `-e GIN_MODE=` | Operational mode for Gin framework. Set to `debug` for noisy log output. Default is `release`. |
| `-e CROWDSEC_BOUNCER_SKIPRFC1918=` | Don't send RCF1918 (Private) IP addresses to the LAPI to check ban status. Allowed values: `true`, `false` . Default is `true`. |
| `-e CROWDSEC_BOUNCER_REDIRECT=` | Optionally redirect instead of giving 403 Forbidden. Accepts relative or absolute URLs but must not be protected by the bouncer or you'll get a redirect loop. Default is `null`. |
| `-e CROWDSEC_BOUNCER_CLOUDFLARE=` | Use the `CF-Connecting-IP` header instead of `X-Forwarded-For`. This is useful if you're using Cloudflare proxying as `CF-Connecting-IP` will contain the real source address rather than the Cloudflare address. Allowed values: `true`, `false` . Default is `false`. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```shell
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```shell
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Support Info

* Shell access whilst the container is running: `docker exec -it traefik-crowdsec-bouncer /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f traefik-crowdsec-bouncer`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. We do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull traefik-crowdsec-bouncer`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d traefik-crowdsec-bouncer`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull ghcr.io/thespad/traefik-crowdsec-bouncer`
* Stop the running container: `docker stop traefik-crowdsec-bouncer`
* Delete the container: `docker rm traefik-crowdsec-bouncer`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Image Update Notifications - Diun (Docker Image Update Notifier)

* We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```shell
git clone https://github.com/thespad/docker-traefik-crowdsec-bouncer.git
cd docker-traefik-crowdsec-bouncer
docker build \
  --no-cache \
  --pull \
  -t ghcr.io/thespad/traefik-crowdsec-bouncer:latest .
```

## Versions

* **30.12.23:** - Rebase to Alpine 3.19.
* **14.05.23:** - Rebase to Alpine 3.18. Drop support for armhf.
* **02.05.23:** - Bump Go to 1.20 for build stage.
* **01.05.23:** - Update deps.
* **01.05.23:** - Restructure repo.
* **26.04.23:** - Support CF forwarded IP headers.
* **15.02.22:** - Initial Release.
