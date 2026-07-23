function proj
    set -f delimiter ':::'
    set -f projects
    set -f worktrees

    if test -z "$PROJ_DIR"
        set -f PROJ_DIR "$HOME/src"
    end
    if test -z "$PROJ_DEPTH"
        set -f PROJ_DEPTH 5
    end
    if test -z "$WORKTREES_DIR"
      set -f WORKTREES_DIR "$HOME/worktrees"
    end

    function _usage
        echo "Usage: proj [-h|--help] [-s|--session] [-w|--window] [-t|--worktrees] [--] [<filter>]"
        echo
        echo "Tmux session and window manager for projects in $PROJ_DIR and worktrees in $WORKTREES_DIR"
        echo
        echo "Current projecs directory (\$PROJ_DIR):"
        echo "  $PROJ_DIR"
        echo "Current worktrees directory (\$WORKTREES_DIR):"
        echo "  $WORKTREES_DIR"
        echo
        echo "  -w, --window     Switch to a tmux window for the selected project"
        echo "  -s, --session    Switch to a tmux session for the selected project (default)"
        echo "  -t, --worktrees  List worktrees instead of projects"
        echo "  -h, --help       Show this help message"
    end

    function _format_gitdir -V PROJ_DIR -V delimiter --description "Remove the PROJ_DIR from the git path"
        while read git_dir
            set -l path (dirname $git_dir)
            set -l name (echo $path | sed "s#^$PROJ_DIR/##" | tr . _)
            echo $path$delimiter$name
        end
    end

    argparse --name=proj h/help s/session w/window t/worktrees -- $argv

    set -f view_mode (set -ql _flag_window && echo "window" || echo "session")
    set -f list_mode (set -ql _flag_worktrees && echo "worktrees" || echo "projects")

    if set -ql _flag_session && set -ql _flag_window
        echo -e "Error: --session and --window cannot be used together\n"
        _usage | head -n 1
        return 1
    end

    if test $status -ne 0 || set -ql _flag_help
        _usage
        return 0
    end
    set -f positional $argv

    function maybe_add_project --no-scope-shadowing -V delimiter --description "add a custom alias to the project list"
        set -l name $argv[1]
        set -l path $argv[2]
        test -d $path && set -a projects $path$delimiter$name
    end

    set -a projects (fd '^\.git$' -d $PROJ_DEPTH -HI $PROJ_DIR | _format_gitdir)
    if test -d $WORKTREES_DIR
      set -a worktrees (for dir in (ls -1 $WORKTREES_DIR); echo "$WORKTREES_DIR/$dir$delimiter$dir"; end)
    end

    # Custom aliases
    maybe_add_project dotfiles $HOME/.local/share/chezmoi
    maybe_add_project home $HOME

    # we have to use the 2nd field when the delimiter is multiple characters due
    # because fzf will append delimiters to the selector output
    # see: https://github.com/junegunn/fzf/issues/2154
    switch $list_mode
      case projects
        set -f fzf_args --delimiter="$delimiter" --with-nth=2 --header='Select a project'
        set -f fzf_list $projects
      case worktrees
        set -f fzf_args --delimiter="$delimiter" --with-nth=2 --header='Select a worktree'
        set -f fzf_list $worktrees
      case '*'
        echo "Unknown list mode: $list_mode"
        return 1
    end

    # Run the project picker
    if test -z "$positional"
        # picker mode
        set -f selected "$(string join \n $fzf_list | sort | fzf $fzf_args)"
    else
        # first selection mode
        set -f selected "$(string join \n $fzf_list | sort | fzf $fzf_args --filter "$positional" | head -n 1)"
    end

    if test -z "$selected"
        echo No project selected
        return 1
    end

    set -f selected_path (echo $selected | awk -F $delimiter '{print $1}')
    set -f selected_name (echo $selected | awk -F $delimiter '{print $2}')
    # echo selected_path=$selected_path
    # echo selected_name=$selected_name
    # return 0

    if test ! -d $selected_path
        echo "Invalid project"
        return 1
    end

    if test "$view_mode" = session
        tmux has-session -t $selected_name 2>/dev/null
        if test $status -eq 1
            tmux new-session -d -s $selected_name -c $selected_path
        end
        if test -z "$TMUX"
            tmux attach-session -t "$selected_name"
        else
            tmux switch-client -t "$selected_name"
        end
    else
        tmux renamew $selected_name
        cd $selected_path
    end

    return 0
end
