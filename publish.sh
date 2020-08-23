#!/usr/bin/env bash

set -e

orb="$1"
tag="$2"

circleci config pack "$orb" > "/tmp/$orb.yml"
circleci config validate "/tmp/$orb.yml"
circleci orb publish "/tmp/$orb.yml" "haskell-works/$orb@$tag"
