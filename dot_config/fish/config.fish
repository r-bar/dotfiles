if type -q eza
  set -g __fish_ls_command eza
end
set -gx EDITOR nvim
# keep go compiler droppings out of my home folder
set -gx GOPATH $HOME/.cache/go

set -gx UPLOAD_RCLONE_CONFIG linode
set -gx UPLOAD_BUCKET barth-tech
set -gx UPLOAD_BASE_PATH uploads

set -gx FZF_TMUX 1

if type -q gcloud && type -q uv
  set -gx CLOUDSDK_PYTHON (uv python find 3.12)
end

if type -q rustup && type -q rustc && test -d (rustc --print sysroot)/bin
  set fish_user_paths (rustc --print sysroot)/bin $fish_user_paths
end
if test -d ~/.cargo/bin
  set fish_user_paths ~/.cargo/bin $fish_user_paths
end
set fish_user_paths ~/.local/bin $fish_user_paths

config_homebrew
# Unpinned: the per-prompt env re-execution bug that forced the 2025.10.21
# pin is fixed as of mise 2026.7.6, and the pinned script broke PATH ordering
# in new tmux panes (stale __MISE_DIFF + no PATH reset).
config_activate_mise
