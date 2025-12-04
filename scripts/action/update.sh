#!/usr/bin/env bash
set -e

version=""

while IFS= read -r -d '' f; do
	# versionがコメントに書かれている場合
	version="$(yq '.jobs.*.steps[].uses | select(. == "super-linter/super-linter*") | line_comment' "${f}")"
	if [[ -z "${version}" || ! "${version}" =~ ^v.+ ]]; then
		version="$(yq '.jobs.*.steps[].uses | select(. == "super-linter/super-linter*")' "${f}" | sed -e 's/.*@//g')"
	fi
	if [[ "${version}" =~ ^v.+ ]]; then
		break
	fi
done < <(find .github/workflows -type f -print0)

echo "super-linter version = ${version}"

if [ -z "${version}" ]; then
	exit 1
fi

curl "https://raw.githubusercontent.com/super-linter/super-linter/${version}/TEMPLATES/.gitleaks.toml" >.gitleaks.toml
yq -i ".repos[].rev = \"$(docker run --entrypoint gitleaks "ghcr.io/super-linter/super-linter:slim-${version}" version | sed -e 's/\r//g')\"" .pre-commit-config.yaml
