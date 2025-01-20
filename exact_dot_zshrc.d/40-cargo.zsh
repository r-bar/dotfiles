if hash rustc 2> /dev/null && [ -f "$(rustc --print sysroot)/share/zsh/site-functions/_cargo" ]; then
  fpath+="$(rustc --print sysroot)/share/zsh/site-functions/_cargo"
fi
