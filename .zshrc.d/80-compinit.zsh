# initialize zsh completions

zcachedir=${zcachedir:-$HOME/.cache/zsh/}
[[ -d "$zcachedir" ]] || mkdir -p "$zcachedir"

_update_zcomp() {
  setopt local_options
  setopt extendedglob
  autoload -Uz compinit
  local zcompf="$1/zcompdump"
  # use a separate file to determine when to regenerate, as compinit doesn't
  # always need to modify the compdump
  local zcompf_a="${zcompf}.augur"

  if [[ -e "$zcompf_a" && -f "$zcompf_a"(#qN.md-1) ]]; then
    compinit -C -d "$zcompf"
  else
    compinit -d "$zcompf"
    touch "$zcompf_a"
  fi
  # if zcompdump exists (and is non-zero), and is older than the .zwc file,
  # then regenerate
  if [[ -s "$zcompf" && (! -s "${zcompf}.zwc" || "$zcompf" -nt "${zcompf}.zwc") ]]; then
    echo Recompiled completions
    # since file is mapped, it might be mapped right now (current shells), so
    # rename it then make a new one
    [[ -e "$zcompf.zwc" ]] && mv -f "$zcompf.zwc" "$zcompf.zwc.old"
    # compile it mapped, so multiple shells can share it (total mem reduction)
    # run in background
    zcompile -M "$zcompf" &!
  fi
}
_update_zcomp "$zcachedir"
unfunction _update_zcomp

#promptinit

# initialize bash completions functions
autoload -U +X bashcompinit && bashcompinit
