#!/usr/bin/env bash

npm ci
action_version="$(yq '.jobs.build.steps[-1].uses | line_comment' .github/workflows/super-linter.yml)"
PATH="$(docker run --rm --entrypoint '' "ghcr.io/slim-${action_version}" /bin/sh -c 'echo $PATH')"
echo "PATH=/github/workspace/node_modules/.bin:${PATH}" >> "$GITHUB_ENV"
