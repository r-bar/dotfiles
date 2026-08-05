function cw --description 'Change tmux window'
  argparse --name cw 'h/help' -- $argv
  set -f window $argv[1]
  if set -q _flag_help
    echo "Usage: cw [-h|--help] [<window>]"
    return 0
  end

  if test -z "$TMUX"
    echo No active tmux session
    return 1
  end
  
  set -f awk_script '{gsub(/:$/, "", $1); print($1, $2)}'
  if test -z "$window"
    set -f selected (tmux lsw | awk "$awk_script" | fzf)
    echo "selected=$selected"
  else
    set -f selected (tmux lsw | awk "$awk_script" | fzf --filter "$window")
  end

  if test -z "$selected"
    echo No matching window
    return 1
  end

  set -l target (echo $selected | awk '{print $1}')

  tmux select-window -t $target
end
