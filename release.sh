#!/usr/bin/env bash

set -x
set -euo pipefail

VERSION_MAJOR="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.major')"
VERSION_MINOR="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.minor')"
VERSION_PATCH="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.patch')"

OLDVERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

NEWVERSION="${1:-}"

if [[ "$NEWVERSION" == "" ]]; then
    echo "No version specified"
    exit 1
fi

echo "Old version: $OLDVERSION"

echo "New version: $NEWVERSION"


NEWVERSION_MAJOR="$(echo $NEWVERSION| cut -d'.' -f1)"

NEWVERSION_MINOR="$(echo $NEWVERSION | cut -d'.' -f2)"

NEWVERSION_PATCH="$(echo $NEWVERSION | cut -d'.' -f3)"

sed -i "s|$OLDVERSION|$NEWVERSION|" mod_info.json

sed -i "s|\"major\":$VERSION_MAJOR|\"major\":$NEWVERSION_MAJOR|" bedlamskunkworks.version 

sed -i "s|\"minor\":$VERSION_MINOR|\"minor\":$NEWVERSION_MINOR|" bedlamskunkworks.version 

sed -i "s|\"patch\":$VERSION_PATCH|\"patch\":$NEWVERSION_PATCH|" bedlamskunkworks.version 

TEMPDIR="$(mktemp -d)/Bedlam Skunkworks"

mkdir -p "$TEMPDIR"

echo "tempdir: $TEMPDIR"

cp -r * "$TEMPDIR"

rm -rf "$TEMPDIR"/{release.sh,bin,lib,src}

TEMPDIRFORZIP=$(mktemp -d)

pushd "$TEMPDIR"

cd ..

RELEASEZIP="$TEMPDIRFORZIP/Bedlam_Skunkworks.zip"

zip -q -r "$RELEASEZIP" "Bedlam Skunkworks"

popd

git add mod_info.json bedlamskunkworks.version
git commit -m "v${NEWVERSION}"
git push origin "$(git branch --show-current)"

gh release create "v${NEWVERSION}" -t "v${NEWVERSION}" --target "$(git branch --show-current)" --generate-notes "$RELEASEZIP"