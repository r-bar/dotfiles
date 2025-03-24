#!/bin/sh

if [ $CHEZMOI -eq 1 ] && [ -n "$CHEZMOI_SOURCE_DIR" ]; then
  cd $CHEZMOI_SOURCE_DIR
fi

pre-commit install
