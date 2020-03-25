@"
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# This is not nice, but unfortunately TERM does not work
STOPSIGNAL SIGKILL

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["varnish-agent", "-d"]
"@