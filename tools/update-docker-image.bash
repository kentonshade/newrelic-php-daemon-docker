#!/usr/bin/env bash
set -ex

if [[ ! "$1" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]{3} ]]; then
  echo "ERROR: A full version string must be passed in"
  exit 1
fi

version=$1
version_short=$(echo $1 | awk -F "." '{print $1 "." $2 "." $3}')

wget -O /tmp/newrelic-php5-"${version}"-linux-musl.tar.gz https://download.newrelic.com/php_agent/archive/"${version}"/newrelic-php5-"${version}"-linux-musl.tar.gz;

sha=$(sha256sum /tmp/newrelic-php5-${version}-linux-musl.tar.gz | awk '{print $1}')

mkdir "${version_short}"

cp docker-entrypoint-template "${version_short}"/docker-entrypoint.sh
cd "${version_short}"

sed \
   -e s/"ENV[[:space:]]NEWRELIC_VERSION/ENV NEWRELIC_VERSION ${version}"/ \
   -e s/"ENV[[:space:]]NEWRELIC_SHA/ENV NEWRELIC_SHA ${sha}"/ \
    ../Dockerfile-template > Dockerfile

# GHA git configs (Change for prod)
git config user.email "kshade@newrelic.com"
git config user.name "Kenton Shade"

git checkout -b "${version_short}"
# GHA: Below is only for testing
# to catch the test txt file
cd ../
# GHA: Below includes deletions
git add -A .
git commit -m "version bump to ${version_short}"
