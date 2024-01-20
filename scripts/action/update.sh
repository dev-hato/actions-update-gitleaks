#!/usr/bin/env bash

version=""

while IFS= read -r -d '' f; do
  v="$(yq '.jobs.*.steps[].uses | select(. == "super-linter/super-linter*")' "${f}" | sed -e 's/.*@//g')"
  if [ -n "${v}" ]; then
    if [[ "${v}" == *" # v"* ]]; then
        v="${v#* # }"
    fi
    version="${v}"
    break
  fi
done < <(find .github/workflows -type f -print0)

echo "super-linter version = ${version}"
curl "https://raw.githubusercontent.com/super-linter/super-linter/${version}/TEMPLATES/.gitleaks.toml" >.gitleaks.toml
yq -i ".repos[].rev = \"$(docker run --entrypoint gitleaks "ghcr.io/super-linter/super-linter:slim-${version}" version | sed -e 's/\r//g')\"" .pre-commit-config.yaml
