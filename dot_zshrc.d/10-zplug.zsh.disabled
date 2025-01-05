###########
# PLUGINS #
###########

# install zplug if it is not installed already
if ! [[ -d $HOME/.zplug ]]; then
  echo Installing zplug...
  # this is the officially documented command, but appears to be broken on zsh
  # >=5.8
  #curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  git clone https://github.com/zplug/zplug.git $HOME/.zplug
fi
source $HOME/.zplug/init.zsh

zplug zsh-users/zsh-completions
zplug zsh-users/zsh-autosuggestions
zplug zsh-users/zsh-syntax-highlighting, defer:2
zplug romkatv/powerlevel10k, as:theme
# this should not be necessary with the new `p10k configure` command`
#zplug romkatv/dotfiles-public, as:plugin, \
#  use:'/.purepower'
#zplug zpm-zsh/clipboard
zplug Tarrasch/zsh-command-not-found
zplug zpm-zsh/ssh
zplug romkatv/zsh-prompt-benchmark
zplug wfxr/forgit
#zplug r-bar/zsh-vim-mode, defer:3

# Install plugins if there are plugins that have not been installed
if ! zplug check; then zplug install; fi
