# CircleCI orbs

A set of orbs for continuous integration for Haskell projects.

Published versions can be found in the official [CircleCI Orbs Registry](https://circleci.com/orbs/registry/)

https://circleci.com/orbs/registry/orb/haskell-works/haskell-build

https://circleci.com/orbs/registry/orb/haskell-works/github-release

https://circleci.com/orbs/registry/orb/haskell-works/hackage

https://circleci.com/orbs/registry/orb/haskell-works/docker-publish

## Building and publishing

```
$ circleci config pack haskell-build > /tmp/haskell-build.yml
$ circleci orb publish /tmp/haskell-build.yml haskell-works/haskell-build@dev:nexgen
```


## Examples

Always look for latest versions of orbs when you use them.

### Building an application

**Note** that publishing a docker container would require env variable
`DOCKER_USERNAME` and `DOCKER_PASSWORD` to be set.

```
version: 2.1

orbs:
  haskell: haskell-works/haskell-build@1.3.1
  github: haskell-works/github-release@1.2.1
  docker: haskell-works/docker-publish@1.0.0

workflows:
  multiple-ghc-build:
    jobs:
      - haskell/build:
          name: Build
          executor: haskell/ghc-8_4_4
          write-result-workspace: true

      - docker/publish:
          name: Docker
          requires: [Build]
          attach-workspace: true
          source-env-file: ./build/project.env
          registry: quay.io
          image: ${BUILD_EXE_NAME}_${BUILD_EXE_VERSION}
          tag: $(if [ "$CIRCLE_BRANCH" = "master" ]; then echo ${CIRCLE_BUILD_NUM}; else echo "${CIRCLE_BUILD_NUM}-${CIRCLE_SHA1:0:5}"; fi)

      - github/release-cabal:
          name: GitHub Release
          requires: [Build, Docker]
          checkout: true
          attach-workspace: true
          artefacts-folder: ./build
          filters:
            branches:
              only: master

```

### Building a library

This configuration will build a project with multiple GHCs
and then release this project to GitHub and Hackage.

```
version: 2.1

orbs:
  haskell: haskell-works/haskell-build@1.3.1
  github: haskell-works/github-release@1.2.1
  hackage: haskell-works/hackage@1.0.0


workflows:
  multiple-ghc-build:
    jobs:
      - haskell/build:
          name: GHC 8.4.4
          executor: haskell/ghc-8_4_4

      - haskell/build:
          name: GHC 8.6.3
          executor: haskell/ghc-8_6_3

      - github/release-cabal:
          name: GitHub Release
          requires:
            - GHC 8.4.4
            - GHC 8.6.3
          checkout: true
          filters:
            branches:
              only: master

      - hackage/upload:
          publish: true
          requires:
            - GitHub Release
```
