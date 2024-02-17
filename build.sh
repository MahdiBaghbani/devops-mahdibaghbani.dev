#!/usr/bin/env bash

# halt on errors.
set -e

function updateGitRepository () {
  cd  "${1}"
  git fetch --all
  git reset --hard origin/master
  git pull
  cd "${2}"
}

# check if zola is installed.
if ! command -v zola &> /dev/null; then
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

git submodule update --init --recursive

updateGitRepository ./mahdibaghbani.dev-volumes/mahdibaghbani.dev "${DIR}"
updateGitRepository ./mahdibaghbani.dev-volumes/mahdibaghbani.dev/themes/erfan "${DIR}"

cd ./mahdibaghbani.dev-volumes/mahdibaghbani.dev
zola build
