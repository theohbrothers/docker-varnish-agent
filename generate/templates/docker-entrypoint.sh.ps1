@'
#!/bin/sh

output() {
    echo "[$( date '+%Y-%m-%d %H:%M:%S %z' )] $1"
}

error() {
    echo "[$( date '+%Y-%m-%d %H:%M:%S %z' )] $1" >&2
}

# Varnish Agent env vars
VARNISH_HOST="${VARNISH_HOST:-varnish}"
VARNISH_HOST_MANAGEMENT_PORT="${VARNISH_HOST_MANAGEMENT_PORT:-6082}"
VARNISH_AGENT_USER="${VARNISH_AGENT_USER:-admin}"
VARNISH_AGENT_PASSWORD="${VARNISH_AGENT_PASSWORD:-admin}"
VARNISH_AGENT_PORT="${VARNISH_AGENT_PORT:-6085}"

# Varnish Dashboard env vars
DASHBOARD_ENABLED="${DASHBOARD_ENABLED:-}"
DASHBOARD_VARNISH_SERVER_DISPLAY_NAME="${DASHBOARD_VARNISH_SERVER_DISPLAY_NAME:-Varnish}"

if [ ! -z "$DASHBOARD_ENABLED" ]; then
    output "Varnish Dashboard will be enabled"
fi

# Generate varnish agent command line
if [ -z "$1" ] || [ "$1" = "varnish-agent" ]; then
    set -- varnish-agent -d -T "$VARNISH_HOST:$VARNISH_HOST_MANAGEMENT_PORT" -u root -g root

    if [ ! -z "$VARNISH_AGENT_PORT" ]; then
        set -- "$@" -c "$VARNISH_AGENT_PORT"
    fi

    if [ ! -z "$DASHBOARD_ENABLED" ]; then
        set -- "$@" -H /var/www/html/varnish-dashboard
    fi
fi

# Setup the Varnish Agent secret
AGENT_SECRET_FILE=/usr/local/etc/varnish/agent_secret
if [ ! -f "$AGENT_SECRET_FILE" ] && [ ! -z "$VARNISH_AGENT_USER" ] && [ ! -z "$VARNISH_AGENT_PASSWORD" ]; then
    mkdir -p /usr/local/etc/varnish
    echo "${VARNISH_AGENT_USER:-admin}:${VARNISH_AGENT_PASSWORD:-admin}" > "$AGENT_SECRET_FILE"
fi

# Setup Varnish Dashboard if required
if [ "$DASHBOARD_ENABLED" = 1 ]; then
    # It is important that 'port' is null to ensure the Dashboard frontend urls dont get appended :PORT causing the Dashboard to break when we are using HTTP(80) or HTTPS(443). See: https://github.com/brandonwamboldt/varnish-dashboard/issues/14#issuecomment-389463866
    echo "$(cat - <<'EOF'
var config = {
    servers: [{
        name: "DASHBOARD_VARNISH_SERVER_DISPLAY_NAME",
        host: null,
        port: null,
        user: false,
        pass: false
    }],  groups: [],
    update_freq: 2000,
    max_points: 100,
    default_log_fetch: 10000,
    default_log_display: 100,
    show_bans_page: true,
    show_manage_server_page: true,
    show_vcl_page: true,
    show_stats_page: true,
    show_params_page: true,
    show_logs_page: true,
    show_restart_varnish_btn: true
};
EOF
    )" \
    | sed "s/DASHBOARD_VARNISH_SERVER_DISPLAY_NAME/$DASHBOARD_VARNISH_SERVER_DISPLAY_NAME/" \
    > /var/www/html/varnish-dashboard/config.js
fi

# Start Varnish Agent in foreground
exec "$@"
'@