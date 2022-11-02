#!/usr/bin/env bash

version=""

while IFS= read -r -d '' f; do
  v="$(yq '.jobs.*.steps[].uses | select(. == "github/super-linter*")' "${f}" | sed -e 's/.*@//g')"
  if [ -n "${v}" ]; then
    version="${v}"
    break
  fi
done < <(find .github/workflows -type f -print0)

curl "https://raw.githubusercontent.com/github/super-linter/${version}/TEMPLATES/.gitleaks.toml" >.gitleaks.toml
yq -i ".repos[].rev = \"$(docker run --entrypoint gitleaks "github/super-linter:slim-${version}" version | sed -e 's/\r//g')\"" .pre-commit-config.yaml
