#!/usr/bin/env bash

NERDFONT_VERSION=v3.4.0
FONTS=(
  "FiraCode"
  "FiraMono"
  "Hack"
  "Iosevka"
  "IosevkaTerm"
  "SourceCodePro"
)
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download"

mkdir -p ~/.fonts
cd ~/.fonts

for font in ${FONTS[*]}; do
  echo Fetching $font font ...
  curl -sLf "$BASE_URL/$NERDFONT_VERSION/$font.tar.xz" -o "$font.tar.xz"
  if [[ ! -f "$font.tar.xz" ]]; then
    echo Failed to download $font
    continue
  fi
  file_list="$(tar tf $font.tar.xz | grep '.ttf$\|.otf$')"
  tar xf "$font.tar.xz" $file_list
  rm "$font.tar.xz"
done

exit 0
