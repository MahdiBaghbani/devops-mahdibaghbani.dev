#!/usr/bin/env bash

# halt on errors.
set -e

function updateGitRepository () {
  cd  "${1}"
  git fetch --all                   >/dev/null 2>&1
  git reset --hard origin/"${3}"    >/dev/null 2>&1
  git pull origin "${3}"            >/dev/null 2>&1
  cd "${2}"
}

# check if zola is installed.
if ! command -v zola >/dev/null 2>&1; then
    echo "Zola is not installed. Cannot build."
    exit
fi

# find this scripts location.
SOURCE=${BASH_SOURCE[0]}
while [ -L "${SOURCE}" ]; do # resolve ${SOURCE} until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "${SOURCE}")
   # if ${SOURCE} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ ${SOURCE} != /* ]] && SOURCE=${DIR}/${SOURCE}
done
DIR=$( cd -P "$( dirname "${SOURCE}" )" >/dev/null 2>&1 && pwd )

# go to the scripts directory.
cd "${DIR}" || exit

docker compose down --remove-orphans >/dev/null 2>&1 || true

git submodule update --init --recursive >/dev/null 2>&1

updateGitRepository "${DIR}" "${DIR}" master
updateGitRepository ./volumes/mahdibaghbani.dev "${DIR}" master
updateGitRepository ./volumes/mahdibaghbani.dev/themes/tabi "${DIR}" main

cd ./volumes/mahdibaghbani.dev
zola build >/dev/null 2>&1
cd "${DIR}"

docker compose up --detach >/dev/null 2>&1 || true
