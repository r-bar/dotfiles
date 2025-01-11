#function bind_bang
#  switch (commandline -t)
#  case "!"
#    commandline -t -- $history[1]
#    commandline -f repaint
#  case "*"
#    commandline -i !
#  end
#end

#function bind_dollar
#  switch (commandline -t)
#  # Variation on the original, vanilla "!" case
#  # ===========================================
#  #
#  # If the `!$` is preceded by text, search backward for tokens that
#  # contain that text as a substring. E.g., if we'd previously run
#  #
#  #   git checkout -b a_feature_branch
#  #   git checkout main
#  #
#  # then the `fea!$` in the following would be replaced with
#  # `a_feature_branch`
#  #
#  #   git branch -d fea!$
#  #
#  # and our command line would look like
#  #
#  #   git branch -d a_feature_branch
#  #
#  case "*!"
#    commandline -f backward-delete-char history-token-search-backward
#  case "*"
#    commandline -i '$'
#  end
#end

function last_history_item --description "Return the previous command line"
  echo $history[1]
end

function last_history_args --description "Return the arguments of the last command line"
  echo $history[1] | awk '{$1=""; print $0}'
end

function last_history_arg --description "Returns the last argument of the last history item"
  echo $history[1] | awk '{print $NF}'
end

function fish_user_key_bindings
  fish_vi_key_bindings
  fzf_configure_bindings --directory=\ct
  #bind -M insert ! bind_bang
  #bind -M insert '$' bind_dollar
  # somewhere along the way ctrl-f gets unbound. Add it back.
  bind -M insert ctrl-f accept-autosuggestion
  # for compatability with my old zsh config
  bind -M insert ctrl-space accept-autosuggestion


  abbr --add k kubectl
  abbr --add kcd kubectl config use-context
  abbr --add kns kubectl config set-context --namespace

  abbr --add cm chezmoi
  abbr --add cme chezmoi edit --apply

  abbr --add ll ls -al
  abbr --add la ls -a
  abbr --add l

  abbr --add mr mise run
  abbr --add gco git switch
  abbr --add gsw git switch

  abbr --add !! --position anywhere --function last_history_item
  abbr --add !\* --position anywhere --function last_history_args
  abbr --add !@ --position anywhere --function last_history_args
  abbr --add !\$ --position anywhere --function last_history_arg
end
