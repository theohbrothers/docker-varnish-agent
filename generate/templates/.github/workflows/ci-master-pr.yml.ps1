@'
name: ci-master-pr

on:
  push:
    branches:
    - master
    - release # For Generate-DockerImageVariants: For CalVer releases. Each push to 'release' branch is a time-based release.
  pull_request:
    branches:
    - master
jobs:
'@

$local:WORKFLOW_JOB_NAMES = $VARIANTS | % { "build-$( $_['tag'].Replace('.', '-') )" }
$( $VARIANTS | % {
@"


  build-$( $_['tag'].Replace('.', '-') ):
    runs-on: ubuntu-latest
    env:
      VARIANT_TAG: $( $_['tag'] )
      # VARIANT_TAG_WITH_REF: $( $_['tag'] )-`${GITHUB_REF}
      VARIANT_BUILD_DIR: $( $_['build_dir_rel'] )
"@
@'

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Display system info (linux)
      run: |
        set -e
        hostname
        whoami
        cat /etc/*release
        lscpu
        free
        df -h
        pwd
        docker info
        docker version

    # See: https://github.com/docker/build-push-action/blob/v2.6.1/docs/advanced/cache.md#github-cache
    - name: Set up QEMU
      uses: docker/setup-qemu-action@v1

    - name: Set up Docker Buildx
      id: buildx
      uses: docker/setup-buildx-action@master

    - name: Cache Docker layers
      uses: actions/cache@v2
      with:
        path: /tmp/.buildx-cache
        key: ${{ runner.os }}-buildx-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-buildx-

    - name: Prepare
      id: prep
      env:
        DOCKERHUB_REGISTRY_USER: ${{ secrets.DOCKERHUB_REGISTRY_USER }}
      run: |
        set -e

        # Get 'namespace' and 'project-name' from 'namespace/project-name'
        # CI_PROJECT_NAMESPACE=$( echo "${{ github.repository }}" | cut -d '/' -f 1 )
        # CI_PROJECT_NAME=$( echo "${{ github.repository }}" | cut -d '/' -f 2 )

        # Get 'ref-name' from 'refs/heads/ref-name'
        REF=$( echo "${GITHUB_REF}" | rev | cut -d '/' -f 1 | rev )
        SHA_SHORT=$( echo "${GITHUB_SHA}" | cut -c1-7 )

        # For Generate-DockerImageVariants: Generate the final tags. E.g. 'master-v1.0.0-alpine' and 'master-b29758a-v1.0.0-alpine'
        VARIANT_TAG_WITH_REF="${REF}-${VARIANT_TAG}"
        VARIANT_TAG_WITH_REF_AND_SHA_SHORT="${REF}-${SHA_SHORT}-${VARIANT_TAG}"

        # Set step output(s)
        # echo "::set-output name=CI_PROJECT_NAMESPACE::$CI_PROJECT_NAMESPACE"
        # echo "::set-output name=CI_PROJECT_NAME::$CI_PROJECT_NAME"
        # echo "::set-output name=REF::$REF"
        # echo "::set-output name=SHA_SHORT::$SHA_SHORT"
        # echo "::set-output name=REF_AND_SHA_SHORT::$REF_AND_SHA_SHORT"

        # For Generate-DockerImageVariants: Set step output(s)
        echo "::set-output name=CONTEXT::$VARIANT_BUILD_DIR"
        echo "::set-output name=VARIANT_TAG::$VARIANT_TAG"
        echo "::set-output name=VARIANT_TAG_WITH_REF::$VARIANT_TAG_WITH_REF"
        echo "::set-output name=VARIANT_TAG_WITH_REF_AND_SHA_SHORT::$VARIANT_TAG_WITH_REF_AND_SHA_SHORT"

    - name: Login to docker registry
      run: echo "${DOCKERHUB_REGISTRY_PASSWORD}" | docker login -u "${DOCKERHUB_REGISTRY_USER}" --password-stdin
      env:
        DOCKERHUB_REGISTRY_USER: ${{ secrets.DOCKERHUB_REGISTRY_USER }}
        DOCKERHUB_REGISTRY_PASSWORD: ${{ secrets.DOCKERHUB_REGISTRY_PASSWORD }}

    - name: Build (PRs)
      id: docker_build_pr
      # Run only on pull requests
      if: github.event_name == 'pull_request'
      uses: docker/build-push-action@v2
      with:
        context: ${{ steps.prep.outputs.CONTEXT }}
        platforms: linux/amd64
        push: false
        tags: |
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF }}
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF_AND_SHA_SHORT }}
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache

    - name: Build and push (master)
      id: docker_build_master
      # Run only on master
      if: github.ref == 'refs/heads/master'
      uses: docker/build-push-action@v2
      with:
        context: ${{ steps.prep.outputs.CONTEXT }}
        platforms: linux/amd64
        push: true
        tags: |
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF }}
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF_AND_SHA_SHORT }}
        cache-to: type=local,dest=/tmp/.buildx-cache

    - name: Build and push (release)
      id: docker_build_release
      # For Generate-DockerImageVariants: For CalVer releases. Each push to 'release' branch is a time-based release.
      # if: startsWith(github.ref, 'refs/tags/')
      if: github.ref == 'refs/heads/release'
      uses: docker/build-push-action@v2
      with:
        context: ${{ steps.prep.outputs.CONTEXT }}
        platforms: linux/amd64
        push: true
        tags: |
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG }}
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF }}
          ${{ github.repository }}:${{ steps.prep.outputs.VARIANT_TAG_WITH_REF_AND_SHA_SHORT }}

'@

if ( $_['tag_as_latest'] ) {
@'
          ${{ github.repository }}:latest

'@
}
@'
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache

    - name: List docker images
      run: docker images

    - name: Clean-up
      run: docker logout
      if: always()
'@
})

@"


  # For Generate-DockerImageVariants: For CalVer releases. Each push to 'release' branch is a time-based release.
  converge-master-and-release-branches:
    needs: [$( $local:WORKFLOW_JOB_NAMES -join ', ' )]
    if: github.ref == 'refs/heads/release'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Merge release into master (fast-forward)
        run: |
          git checkout master
          git merge release
          git push origin master
"@

@'


  # For Generate-DockerImageVariants: For CalVer releases. Each push to 'release' branch is a time-based release.
  resolve-release-tag:
    runs-on: ubuntu-latest
    outputs:
      TAG: ${{ steps.resolve-release-tag.outputs.TAG }}
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Resolve release tag
        id: resolve-release-tag
        run: |
          set +e
          # E.g. 20210402
          TODAYS_DATE=$( date -u '+%Y%m%d' )
          # Is this the first tag for this date?
          TODAYS_DATE_TAGS=$( git tag --list | grep "^$TODAYS_DATE" )
          TAG=
          if [ -z "$TODAYS_DATE_TAGS" ]; then
              # E.g. 20210402.0.0
              TAG="$TODAYS_DATE.0.0" # Send this to stdout
          else
              # E.g. if there are 20210402.0.0, 20210402.0.1, 20210402.0.2, this returns 2
              VERSION_MINOR_LATEST=$( echo "$TODAYS_DATE_TAGS" | cut -d '.' -f 3 | sort -nr | head -n1 )
              # Minor version
              VERSION_MINOR=$( expr "$VERSION_MINOR_LATEST" + 1 )
              # E.g. 20210402.0.3
              TAG="$TODAYS_DATE.0.$VERSION_MINOR"  # Send this to stdout
          fi
          echo "TODAYS_DATE: $TODAYS_DATE"
          echo "TODAYS_DATE_TAGS: $TODAYS_DATE_TAGS"
          echo "TAG: $TAG"
          echo "::set-output name=TAG::$TAG"
      - name: Print outputs
        run: echo ${{ steps.resolve-release-tag.outputs.TAG }}
'@

@"


  update-draft-release:
    needs: [$( $local:WORKFLOW_JOB_NAMES -join ', ' ), resolve-release-tag]
"@
@'

    if: github.ref == 'refs/heads/master'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Print inputs
        run: echo ${{ needs.resolve-release-tag.outputs.TAG }}
      # Drafts your next Release notes as Pull Requests are merged into "master"
      - uses: release-drafter/release-drafter@v5
        with:
          config-name: release-drafter.yml
          publish: false
          name: ${{ needs.resolve-release-tag.outputs.TAG }}
          tag: ${{ needs.resolve-release-tag.outputs.TAG }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
'@

@"


  publish-draft-release:
    needs: [$( $local:WORKFLOW_JOB_NAMES -join ', ' ), converge-master-and-release-branches, resolve-release-tag]
"@
@'

    # For Generate-DockerImageVariants: For CalVer releases. Each push to 'release' branch is a time-based release.
    # if: startsWith(github.ref, 'refs/tags/')
    if: github.ref == 'refs/heads/release'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # Drafts your next Release notes as Pull Requests are merged into "master"
      - uses: release-drafter/release-drafter@v5
        with:
          config-name: release-drafter.yml
          publish: true
          name: ${{ needs.resolve-release-tag.outputs.TAG }}
          tag: ${{ needs.resolve-release-tag.outputs.TAG }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

'@
