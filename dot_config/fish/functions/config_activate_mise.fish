function config_activate_mise
  # Interactive shells only. Tide renders its prompt with background
  # `fish -c` workers on every repaint; those source config.fish too, and a
  # fresh mise activation in each worker echoes tool/env status over the
  # prompt and slows rendering. Workers inherit (and are explicitly passed)
  # the parent's PATH, so they don't need activation.
  if ! status is-interactive
    return
  end
  if type -q mise
    set -gx MISE_FISH_AUTO_ACTIVATE 1
    # Do NOT clear __MISE_DIFF/__MISE_SESSION here: `mise activate` reads the
    # inherited __MISE_DIFF to strip the previous shell's mise PATH entries
    # (e.g. state leaked in from the tmux server env) before re-activating,
    # then clears the state itself. Clearing it first leaves stale tool paths
    # buried behind homebrew where hook-env won't touch them.
    if test -n "$argv[1]"
      # NOTE: pinning by capturing `mise activate fish` output no longer
      # works on current mise: the output bakes in the absolute PATH of the
      # machine/shell it was captured on.
      source ~/.config/mise/mise_activate_$argv[1].fish
    else
      mise activate fish | source
    end
  end
end
