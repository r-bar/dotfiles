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
  wget --quiet "$BASE_URL/$NERDFONT_VERSION/$font.tar.xz"
  if [[ $? != 0 ]]; then
    echo Failed to download $font
    continue
  fi
  file_list="$(tar tf $font.tar.xz | grep '.ttf$\|.otf$')"
  tar xf $font.tar.xz $file_list
  rm $font.tar.xz
done

exit 0
