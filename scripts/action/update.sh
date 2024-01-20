#!/usr/bin/env bash

version=""

while IFS= read -r -d '' f; do
  v="$(yq '.jobs.*.steps[].uses | select(. == "super-linter/super-linter*")' "${f}" | sed -e 's/.*@//g')"
  if [[ "${v}" == *" # v"* ]]; then
      v=$(echo "${v}" | sed -e 's/.* # //g')
  fi
  if [ -n "${v}" ]; then
    version="${v}"
    break
  fi
done < <(find .github/workflows -type f -print0)

curl "https://raw.githubusercontent.com/super-linter/super-linter/${version}/TEMPLATES/.gitleaks.toml" >.gitleaks.toml
yq -i ".repos[].rev = \"$(docker run --entrypoint gitleaks "ghcr.io/super-linter/super-linter:slim-${version}" version | sed -e 's/\r//g')\"" .pre-commit-config.yaml
