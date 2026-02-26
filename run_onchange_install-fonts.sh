#!/usr/bin/env bash

NERDFONT_VERSION=v3.4.0
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download"

mkdir -p ~/.fonts
cd ~/.fonts

function from-url() {
  local url="$1"
  local filename=$(basename "$url")
  curl -sLf $url -o $filename
  unpack $filename
}

function unpack() {
  local filename="$1"
  if [[ "$filename" == *.zip ]]; then
    unzip -j -o "$filename" "*.ttf" "*.otf"
    rm "$filename"
  elif [[ "$filename" == *.tar.xz ]]; then
    local file_list="$(tar tf $filename | grep '.ttf$\|.otf$')"
    tar xf "$filename" $file_list
    rm "$filename"
  else
    echo "Unsupported file format: $filename"
  fi
}

function nerdfont() {
  local font=$1
  echo Fetching $font font ...
  curl -sLf "$BASE_URL/$NERDFONT_VERSION/$font.tar.xz" -o "$font.tar.xz"
  if [[ ! -f "$font.tar.xz" ]]; then
    echo Failed to download $font
    continue
  fi
  file_list="$(tar tf $font.tar.xz | grep '.ttf$\|.otf$')"
  tar xf "$font.tar.xz" $file_list
  rm "$font.tar.xz"
}

nerdfont FiraCode
nerdfont FiraMono
nerdfont Hack
nerdfont Iosevka
nerdfont IosevkaTerm
nerdfont SourceCodePro

exit 0
