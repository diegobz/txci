#!/usr/bin/env bash
# Pulls translation files from Transifex whenever a tag called `txpull` is
# pushed to the repo. It also commits the fresh translation files and push the
# changes back to Github. It relies on $TXTOKEN and $GHTOKEN being set as env
# vars for the given repo in Travis CI.

tx_init() {
  echo "Setting up ~/.transifexrc file for transifex-client"
  echo "[https://www.transifex.com]
hostname = https://www.transifex.com
username = api
password = $TXTOKEN
token =" > ~/.transifexrc
}

git_setup() {
  git config --global user.email "bot+travis@transifex.com"
  git config --global user.name "Transifex Bot (Travis)"
}

commit_translation_files() {
  git checkout -b devel
  git add locale/*.po
  git commit -m "Translation update from Transifex [ci skip]"
}

push_translation_files() {
  git remote add origin-travis https://${GHTOKEN}@github.com/diegobz/txci.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-travis devel
}

# Only run once, and only for `txpull` tag
echo $TRAVIS_JOB_NUMBER | grep "\.1$"
if [ $? -eq 0 ] && [ $TRAVIS_TAG == txpull ]
  then
    tx_init
    tx pull --all --force
    if git diff-index --quiet HEAD --; then
        git_setup
        commit_translation_files
        push_translation_files
    fi
fi


