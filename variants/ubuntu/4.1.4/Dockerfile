FROM ubuntu:16.04

RUN VARNISH_AGENT_VERSION="4.1.4" \
    && VARNISH_DASHBOARD_COMMIT="e2cc1c854941c9fac18bdfedba2819fa766a5549" \
    && buildDeps="automake build-essential curl ca-certificates libvarnishapi-dev libmicrohttpd-dev libcurl4-gnutls-dev pkg-config python-docutils git" \
    && runDeps="libvarnishapi1 libmicrohttpd10 libcurl4-gnutls-dev" \
    \
    # Install Varnish Agent
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && curl -o /tmp/vagent2.tar.gz -SL https://github.com/varnish/vagent2/archive/${VARNISH_AGENT_VERSION}.tar.gz \
    && tar -zxvf /tmp/vagent2.tar.gz  -C /tmp/ \
    && rm -rf  /tmp/vagent2.tar.gz \
    && cd /tmp/vagent2-${VARNISH_AGENT_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    \
    # Install Varnish Dashboard
    && mkdir -p /var/www/html \
    && cd /var/www/html \
    && git clone https://github.com/brandonwamboldt/varnish-dashboard.git \
    && cd varnish-dashboard \
    && git checkout ${VARNISH_DASHBOARD_COMMIT} \
    \
    # Cleanup
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Install runtime dependencies
    && apt-get update \
    && apt-get install $runDeps \
    \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a varnish system user in case we need to use it
RUN useradd -r -s /bin/false varnish



COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["varnish-agent", "-d"]