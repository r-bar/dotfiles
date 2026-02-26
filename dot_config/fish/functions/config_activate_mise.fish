function config_activate_mise
  #if ! status is-interactive
  #  return
  #end
  if type -q mise
    set -gx MISE_FISH_AUTO_ACTIVATE 1
    if test -n "$argv[1]"
      source ~/.config/mise/mise_activate_$argv[1].fish
    else
      mise activate fish | source
    end
  end
end
