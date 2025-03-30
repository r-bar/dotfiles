if type -q eza
  set -g __fish_ls_command eza
end
set -gx EDITOR nvim

set -gx UPLOAD_RCLONE_CONFIG linode
set -gx UPLOAD_BUCKET barth-tech
set -gx UPLOAD_BASE_PATH uploads


if test -d ~/.cargo/bin
  set fish_user_paths ~/.cargo/bin $fish_user_paths
end
set fish_user_paths ~/.local/bin $fish_user_paths

config_homebrew
config_activate_mise
