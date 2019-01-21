@"
FROM ubuntu:$( $VARIANT['distro_version'] )

RUN apk add --no-cache curl wget
"@