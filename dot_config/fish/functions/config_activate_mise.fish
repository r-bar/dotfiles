function config_activate_mise
  #if ! status is-interactive
  #  return
  #end
  if type -q mise
    set -gx MISE_FISH_AUTO_ACTIVATE 1
    mise activate fish | source
  end
end
