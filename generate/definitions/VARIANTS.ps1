# Docker image variants' definitions
$VARIANTS = @(
    @{
        _metadata = @{
            components = @( 'varnishdashboard' )
            distro = 'ubuntu'
            distro_version = '16.04'
            VARNISH_AGENT_VERSION = '4.1.4'
            VARNISH_DASHBOARD_COMMIT = "e2cc1c854941c9fac18bdfedba2819fa766a5549"
        }
        tag = '4.1.4-ubuntu-16.04'
    }
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                includeHeader = $true
                includeFooter = $true
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

# Send definitions down the pipeline
$VARIANTS
