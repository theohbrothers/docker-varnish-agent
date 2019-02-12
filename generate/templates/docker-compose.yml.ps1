@'
version: '3.7'
services:

  varnish:
    image: thiagofigueiro/varnish-alpine-docker:3.6
    entrypoint: /bin/sh
    command: -c "varnishd -a :80 -b anon:80 -s malloc,100M -T :$${VARNISH_HOST_MANAGEMENT_PORT}}; exec varnishncsa"
    environment:
      - VARNISH_HOST_MANAGEMENT_PORT=6082
    # The hostname must match for varnish and varnish-agent services so that the Varnish Shared Memory Log created in /var/lib/varnish/$HOSTNAME/_.vsm will be shared by both the varnish and the varnish-agent
    hostname: varnish-host
    ports:
      - "80:80"
    volumes:
      # This tmpfs volume allows the Varnish Shared Memory Log to be shared by both varnish and varnish-agent
      - type: volume
        source: varnish-workdir
        target: /var/lib/varnish/
    networks:
      - varnish-network
      - hello-network

  varnish-agent:

'@ + @"
    image: leojonathanoh/docker-varnish-agent:$( $VARIANT['tag'] )

"@ + @'
    # The hostname must match for varnish and varnish-agent services so that the Varnish Shared Memory Log created in /var/lib/varnish/$HOSTNAME/_.vsm will be shared by both the varnish and the varnish-agent
    hostname: varnish-host
    environment:
      - VARNISH_HOST=varnish
      - VARNISH_HOST_MANAGEMENT_PORT=6082
      - VARNISH_AGENT_PORT=6085
      - DASHBOARD_ENABLED=1
    # It is recommended to use https terminator and proxy in front of both varnish and varnish-agent, so that the containers dont have to publish ports directly on the host.
    ports:
      - "6085:6085"
    volumes:
      # This tmpfs volume allows the Varnish Shared Memory Log to be shared by both varnish and varnish-agent
      - type: volume
        source: varnish-workdir
        target: /var/lib/varnish/
    networks:
      - varnish-network

  anon:
    image: emilevauge/whoami
    networks:
      - hello-network

volumes:
  # This tmpfs volume allows the Varnish Shared Memory Log to be shared by both varnish and varnish-agent
  varnish-workdir:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs

networks:
  varnish-network:
  hello-network:
'@