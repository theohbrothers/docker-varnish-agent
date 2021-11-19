@"
FROM ubuntu:16.04

RUN apt-get update \
    && buildDeps="wget ca-certificates git automake build-essential libvarnishapi-dev libmicrohttpd-dev libcurl4-gnutls-dev pkg-config python-docutils" \
    && apt-get install --no-install-recommends -y `$buildDeps \
    && VARNISH_AGENT_VERSION="$( $VARIANT['_metadata']['VARNISH_AGENT_VERSION'] )" \
    && wget -qO- "https://github.com/varnish/vagent2/archive/`$VARNISH_AGENT_VERSION.tar.gz" > /tmp/vagent2.tar.gz \
    && tar -C /tmp -zxvf /tmp/vagent2.tar.gz \
    && cd "/tmp/vagent2-`$VARNISH_AGENT_VERSION" \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /tmp/vagent2.tar.gz \
    \
    && VARNISH_DASHBOARD_COMMIT="$( $VARIANT['_metadata']['VARNISH_DASHBOARD_COMMIT'] )" \
    && git clone https://github.com/brandonwamboldt/varnish-dashboard.git /var/www/html/varnish-dashboard \
    && cd /var/www/html/varnish-dashboard \
    && git checkout "`$VARNISH_DASHBOARD_COMMIT" \
    && rm -rf .git \
    \
    && apt-get purge --auto-remove -y `$buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    \
    && apt-get update \
    && runDeps="libvarnishapi1 libmicrohttpd10 libcurl4-gnutls-dev" \
    && apt-get install --no-install-recommends -y `$runDeps \
    \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a varnish system user in case we need to use it
RUN useradd -r -s /bin/false varnish

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# This is not nice, but unfortunately TERM does not work
STOPSIGNAL SIGKILL

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["varnish-agent", "-d"]
"@
