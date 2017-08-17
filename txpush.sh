#!/usr/bin/env bash
# Pushes source files to Transifex. It relies on $TXTOKEN being set as env vars
# for the given repo in Travis CI.

tx_init() {
  echo "Setting up ~/.transifexrc file for transifex-client"
  echo "[https://www.transifex.com]
hostname = https://www.transifex.com
username = api
password = $TXTOKEN
token =" > ~/.transifexrc
}

# Only run once, and only on `devel` branch
echo $TRAVIS_JOB_NUMBER | grep "\.1$"
if [ $? -eq 0 ] && [ $TRAVIS_BRANCH == devel ]
  then
    tx_init
    tx push --source --no-interactive
fi


