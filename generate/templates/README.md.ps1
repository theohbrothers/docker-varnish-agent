@"
# docker-varnish-agent

[![github-actions](https://github.com/theohbrothers/docker-varnish-agent/actions/workflows/ci-master-pr.yml/badge.svg?branch=master)](https://github.com/theohbrothers/docker-varnish-agent/actions/workflows/ci-master-pr.yml)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-varnish-agent?style=flat-square)](https://github.com/theohbrothers/docker-varnish-agent/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-varnish-agent/latest)](https://hub.docker.com/r/theohbrothers/docker-varnish-agent)

Dockerized [Varnish Agent](https://github.com/varnish/vagent2), including the [Enhanced Varnish Dashboard](https://github.com/brandonwamboldt/varnish-dashboard).

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
$(
($VARIANTS | % {
    if ( $_['tag_as_latest'] ) {
@"
| ``:$( $_['tag'] )``, ``:latest`` | [View](variants/$( $_['tag'] )) |

"@
    }else {
@"
| ``:$( $_['tag'] )`` | [View](variants/$( $_['tag'] )) |

"@
    }
}) -join ''
)

"@

@'
## Usage

An example `docker-compose.yml` is included demonstrating how to use this image with an separate Varnish image (e.g. [`varnish-alpine-docker`](https://github.com/thiagofigueiro/varnish-alpine-docker)).

## Environment variables

| Name | Default value | Description
|:-------:|:---------------:|:---------:|
| `VARNISH_HOST` | `varnish` | Hostname of the varnish server
| `VARNISH_HOST_MANAGEMENT_PORT` | `6082` | Management port opened by the varnish server
| `VARNISH_AGENT_USER` | `admin` | The Varnish Agent user for basic authentication.
| `VARNISH_AGENT_PASSWORD` | `admin` | The Varnish Agent password for basic authentication.
| `VARNISH_AGENT_PORT` | `6085` | The Varnish Agent port.
| `DASHBOARD_ENABLED` | `''` | Whether you want to use the realtime [`Varnish Dashboard`](https://github.com/brandonwamboldt/varnish-dashboard). If the value is empty, the dashboard is disabled.
| `DASHBOARD_VARNISH_SERVER_DISPLAY_NAME` | `Varnish` | The display name of the varnish instance as seen in the `Varnish Dashboard`.

## `docker-entrypoint.sh`

- At entrypoint, if it does not exist, a Varnish Agent secret file is created in `/usr/local/etc/varnish/agent_secret` in the format `$VARNISH_AGENT_USER:$VARNISH_AGENT_PASSWORD`. By default, that will be `admin:admin`
- Once the container has fully started up, the Varnish Agent / Varnish Dashboard frontend will be ready, and accessible via basic authentication.

## FAQ

Q: Why is there no alpine image?

- At the present moment, alpine is not yet supported by the [Varnish Agent](https://github.com/varnish/vagent2)

## Development

Requires Windows `powershell` or [`pwsh`](https://github.com/PowerShell/PowerShell).

```powershell
# Install Generate-DockerImageVariants module: https://github.com/theohbrothers/Generate-DockerImageVariants
Install-Module -Name Generate-DockerImageVariants -Repository PSGallery -Scope CurrentUser -Force -Verbose

# Edit ./generate templates

# Generate the variants
Generate-DockerImageVariants .
```

'@
