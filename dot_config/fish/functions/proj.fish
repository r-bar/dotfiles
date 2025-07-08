function proj
  set -f delimiter ':::'

  if test -z "$PROJ_DIR"
    set -f PROJ_DIR "$HOME/src"
  end
  if test -z "$PROJ_DEPTH"
    set -f PROJ_DEPTH 3
  end

  function _opterr
    echo >&2 "proj: Unknown option '$1'"
  end

  function _usage
    echo "Usage: proj [-h|--help] [-s|--session <session>] [--] [<filter>]"
  end

  function _format_gitdir -V PROJ_DIR -V delimiter --description "Remove the PROJ_DIR from the git path"
    while read git_dir
      set -l path (dirname $git_dir)
      set -l name (echo $path | sed "s#^$PROJ_DIR/##")
      echo $path$delimiter$name
    end
  end

  argparse --name=proj 'h/help' 's/session' -- $argv
  if test $status -ne 0 || set -ql _flag_help
    _usage
    return 0
  end
  set -f positional $argv

  set -f projects
  # used in conjunction with `source` to add directories to export to the
  # $projects list
  function maybe_add_project -V delimiter
    set -l name $argv[1]
    set -l path $argv[2]
    test -d $path && echo set -a projects $path$delimiter$name
  end

  set -a projects (fd '^\.git$' -d $PROJ_DEPTH -HI $PROJ_DIR | _format_gitdir)
  maybe_add_project chezmoi $HOME/.local/share/chezmoi | source
  maybe_add_project core $HOME/src/appomni/appomni | source

  # we have to use the 2nd field when the delimiter is multiple characters due
  # because fzf will append delimiters to the selector output
  # see: https://github.com/junegunn/fzf/issues/2154
  set -f fzf_args --delimiter="$delimiter" --with-nth=2 --header='Select a project'
  if test -z "$positional"
    set -f selected "$(string join \n $projects | sort | fzf $fzf_args)"
  else
    set -f selected "$(string join \n $projects | sort | fzf $fzf_args --filter "$positional" | head -n 1)"
  end

  if test -z "$selected"
    echo No project selected
    return 1
  end

  set -f selected_path (echo $selected | awk -F $delimiter '{print $1}')
  set -f selected_name (echo $selected | awk -F $delimiter '{print $2}')

  if test ! -d $selected_path
    echo Invalid project
    return 1
  end

  if test -n "$_flag_session" || test -z "$TMUX"
    tmux has-session -t $selected_name 2>/dev/null
    if test $status -eq 1
      tmux new-session -d -s $selected_name -c $selected_path
    end
    if test -z "$TMUX"
      tmux attach-session -t $selected_name
    else
      tmux switch-client -t $selected_name
    end
  else
    tmux renamew $selected_name
    cd $selected_path
  end

  return 0
end
