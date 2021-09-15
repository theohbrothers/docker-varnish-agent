# Docker image variants' definitions
$VARIANTS = @(
    @{
        _metadata = @{
            components = @( 'varnishdashboard' )
            distro = 'ubuntu'
            distro_version = '16.04'
            platforms = 'linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/s390x'
            VARNISH_AGENT_VERSION = '4.1.4'
            VARNISH_DASHBOARD_COMMIT = "e2cc1c854941c9fac18bdfedba2819fa766a5549"
        }
        tag = '4.1.4-ubuntu-16.04'
        tag_as_latest = $true
    }
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                includeHeader = $false
                includeFooter = $false
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
            'docker-entrypoint.sh' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
            'docker-compose.yml' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
