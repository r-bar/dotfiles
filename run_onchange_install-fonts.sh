#!/bin/bash

NERDFONT_VERSION=v3.3.0
FONTS=(
  "Hack"
  "FiraCode"
  "FiraMono"
  "SourceCodePro"
)
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download"

mkdir -p ~/.fonts
cd ~/.fonts

for font in ${FONTS[*]}; do
  echo Fetching $font font ...
  curl -sLf "$BASE_URL/$NERDFONT_VERSION/$font.tar.xz" | xz -d | tar x --wildcards "*.ttf" "*.otf" 2> /dev/null
done
