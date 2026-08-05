# Intentionally empty: shadows /opt/homebrew/share/fish/vendor_conf.d/mise-activate.fish
# (fish loads user conf.d before vendor conf.d and skips same-named vendor files).
# Homebrew's mise formula auto-activates unconditionally on every fish process,
# including non-interactive ones and tmux's reattach-to-user-namespace wrapper,
# stacking with config_activate_mise's own activation. Activation is controlled
# solely by config_activate_mise now.
