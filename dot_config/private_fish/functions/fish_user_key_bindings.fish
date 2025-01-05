function bind_bang
  switch (commandline -t)
  case "!"
    commandline -t -- $history[1]
    commandline -f repaint
  case "*"
    commandline -i !
  end
end

function bind_dollar
  switch (commandline -t)
  # Variation on the original, vanilla "!" case
  # ===========================================
  #
  # If the `!$` is preceded by text, search backward for tokens that
  # contain that text as a substring. E.g., if we'd previously run
  #
  #   git checkout -b a_feature_branch
  #   git checkout main
  #
  # then the `fea!$` in the following would be replaced with
  # `a_feature_branch`
  #
  #   git branch -d fea!$
  #
  # and our command line would look like
  #
  #   git branch -d a_feature_branch
  #
  case "*!"
    commandline -f backward-delete-char history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

function fish_user_key_bindings
  fish_vi_key_bindings
  fzf_configure_bindings --directory=\ct
  bind -M insert ! bind_bang
  bind -M insert '$' bind_dollar
  # somewhere along the way ctrl-f gets unbound. Add it back.
  bind -M insert ctrl-f accept-autosuggestion
  # for compatability with my old zsh config
  bind -M insert ctrl-space accept-autosuggestion
end
