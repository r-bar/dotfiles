function _opterr
  echo >&2 "proj: Unknown option '$1'"
end

function _usage
  echo "Usage: proj [-h|--help] [-s|--session <session>] [--] [<filter>]"
end

function proj
  if test -z "$PROJ_DIR"
    set -f PROJ_DIR "$HOME/src"
  end
  if test -z "$PROJ_DEPTH"
    set -f PROJ_DEPTH 3
  end

  argparse --name=proj 'h/help' 's/session' -- $argv
  if test $status -ne 0 || set -ql _flag_help
    _usage
    return 0
  end
  set -f positional $argv

  set -f git_projects "$(fd '^\.git$' -d $PROJ_DEPTH -HI $PROJ_DIR | while read git_dir; dirname $git_dir; end | sed "s#^$PROJ_DIR/##")"
  set -f projects "$git_projects"

  if test -z "$positional"
    set -f proj_name "$(echo "$projects" | fzf --header 'Select a project')"
  else
    set -f proj_name "$(echo "$projects" | fzf --filter "$positional" | head -n 1)"
  end

  if test -z "$proj_name"
    echo No project selected
    return 1
  end
  if test ! -d $PROJ_DIR/$proj_name
    echo Invalid project
    return 1
  end

  if test -n "$_flag_session" || test -z "$TMUX"
    tmux has-session -t $(basename $proj_name) 2>/dev/null
    if test $status -eq 1
      tmux new-session -d -s $(basename $proj_name) -c $PROJ_DIR/$proj_name
    end
    if test -z "$TMUX"
      tmux attach-session -t $(basename $proj_name)
    else
      tmux switch-client -t $(basename $proj_name)
    end
  else
    tmux renamew $(basename $proj_name)
    cd $PROJ_DIR/$proj_name
  end

  return 0
end
