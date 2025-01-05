function config_activate_mise
  if type mise > /dev/null
    set -gx MISE_FISH_AUTO_ACTIVATE 1
    mise activate fish | source
  end
end
