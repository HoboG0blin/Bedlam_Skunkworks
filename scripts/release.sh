#!/usr/bin/env bash
#Co-authored by Artturin 
set -x
set -euo pipefail

GIT_TOPLEVEL=$(git rev-parse --path-format=relative --show-toplevel)

$GIT_TOPLEVEL/scripts/pathbegone.sh

UNCOMMITTED="$(git status --porcelain)"

if [[ "$UNCOMMITTED" != "" ]]; then
    zenity --error --text "There are uncommitted changes:\n$UNCOMMITTED"
    exit 1
fi

if ! zenity --question --text="Did you remember to commit first?"; then 
    zenity --error --text "Commit first you silly goose"
    exit 1
fi

VERSION_MAJOR="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.major')"
VERSION_MINOR="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.minor')"
VERSION_PATCH="$(cat bedlamskunkworks.version | sed 's|^ *#.*||' | jq '. | .modVersion.patch')"

OLDVERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

NEWVERSION="${1:-}"

if [[ "$NEWVERSION" == "" ]]; then
    NEWVERSION=$(zenity --entry --title "Create a new release" --text="New version number?" --entry-text="$OLDVERSION" 2>/dev/null || true)
    if [[ "$NEWVERSION" == "" ]]; then
        zenity --error --text "No Version Specified"
        exit 1
    fi    
fi

if [[ "$NEWVERSION" == "$OLDVERSION" ]]; then 
    zenity --error --text "New version cannot be the same as the old version!"
    exit 1
fi

zenity --text-info <<EOF
Old ver: $OLDVERSION
New ver: $NEWVERSION
EOF


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

rm -rf "$TEMPDIR"/{scripts,bin,lib,src,graphics/xcf}

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

zenity --info --text "release complete"