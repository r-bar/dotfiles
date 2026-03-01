set -gx PATH /home/ryan/.local/bin /home/ryan/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin /opt/rocm/bin /usr/local/sbin /usr/local/bin /usr/bin /var/lib/flatpak/exports/bin /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl /usr/lib/rustup/bin
functions --erase __mise_env_eval
functions --erase __mise_env_eval_2
functions --erase __mise_cd_hook
functions --erase mise
set -e MISE_SHELL
set -e __MISE_DIFF
set -e __MISE_SESSION
set -gx MISE_SHELL fish
if not set -q __MISE_ORIG_PATH
    set -gx __MISE_ORIG_PATH $PATH
end

function mise
  if test (count $argv) -eq 0
    command mise
    return
  end

  set command $argv[1]
  set -e argv[1]

  if contains -- --help $argv
    command mise "$command" $argv
    return $status
  end

  switch "$command"
  case deactivate shell sh
    # if help is requested, don't eval
    if contains -- -h $argv
      command mise "$command" $argv
    else if contains -- --help $argv
      command mise "$command" $argv
    else
      source (command mise "$command" $argv |psub)
    end
  case '*'
    command mise "$command" $argv
  end
end

function __mise_env_eval --on-event fish_prompt --description 'Update mise environment when changing directories';
    mise hook-env -s fish | source;

    if test "$mise_fish_mode" != "disable_arrow";
        function __mise_cd_hook --on-variable PWD --description 'Update mise environment when changing directories';
            if test "$mise_fish_mode" = "eval_after_arrow";
                set -g __mise_env_again 0;
            else;
                mise hook-env -s fish | source;
            end;
        end;
    end;
end;

function __mise_env_eval_2 --on-event fish_preexec --description 'Update mise environment when changing directories';
    if set -q __mise_env_again;
        set -e __mise_env_again;
        mise hook-env -s fish | source;
        echo;
    end;

    functions --erase __mise_cd_hook;
end;

__mise_env_eval
