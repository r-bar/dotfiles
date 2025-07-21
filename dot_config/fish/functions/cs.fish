function cs --description 'Change tmux session'
  argparse --name cs 'h/help' -- $argv
  set -f session $argv[1]
  if set -q _flag_help
    echo "Usage: cs [-h|--help] [<session>]"
    return 0
  end

  if test -z "$session"
    set -f selected (tmux ls | awk '{gsub(/:$/, "", $1); print $1}' | fzf)
  else
    set -f selected (tmux ls | awk '{gsub(/:$/, "", $1); print $1}' | fzf --filter "$session")
  end

  if test -z "$selected"
    echo No matching session
    return 1
  end

  if test -z "$TMUX"
    tmux attach-session -t $selected
  else
    tmux switch-client -t $selected
  end
end
