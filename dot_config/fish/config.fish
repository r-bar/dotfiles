set -gx EDITOR nvim

if test -d ~/.cargo/bin
  set fish_user_paths ~/.cargo/bin $fish_user_paths
end
set fish_user_paths ~/.local/bin $fish_user_paths
config_homebrew

if status is-interactive
  config_activate_mise
end
