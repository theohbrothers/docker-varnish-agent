# Docker image variants' definitions
$VARIANTS_VERSION = "1.0.2"
$VARIANTS = @(
    @{
        tag = '4.1.4'
        distro = 'ubuntu'
        VARNISH_DASHBOARD_COMMIT = "e2cc1c854941c9fac18bdfedba2819fa766a5549"
    }
    @{
        tag = '4.0.2'
        distro = 'ubuntu'
        VARNISH_DASHBOARD_COMMIT = "e2cc1c854941c9fac18bdfedba2819fa766a5549"
    }
)

# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    version = $VARIANTS_VERSION
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false
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