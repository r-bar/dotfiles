if type -q eza
  set -g __fish_ls_command eza
end
set -gx EDITOR nvim
# keep go compiler droppings out of my home folder
set -gx GOPATH $HOME/.cache/go

set -gx UPLOAD_RCLONE_CONFIG linode
set -gx UPLOAD_BUCKET barth-tech
set -gx UPLOAD_BASE_PATH uploads

if type -q gcloud && type -q uv
  set -gx CLOUDSDK_PYTHON (uv python find 3.12)
end


if test -d ~/.cargo/bin
  set fish_user_paths ~/.cargo/bin $fish_user_paths
end
set fish_user_paths ~/.local/bin $fish_user_paths

config_homebrew
config_activate_mise
