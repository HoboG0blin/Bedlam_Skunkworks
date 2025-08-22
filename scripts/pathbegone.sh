#!/usr/bin/env bash
#Co-authored by Artturin 

set -euo pipefail

GIT_TOPLEVEL=$(git rev-parse --path-format=relative --show-toplevel)

FILES=$(grep --files-with-match --exclude-dir "scripts" -R "mods/Bedlam_Skunkworks/" $GIT_TOPLEVEL)

for file in $FILES; do
    sed -i 's|mods/Bedlam_Skunkworks/||' $file    
done