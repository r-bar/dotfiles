############
# SETTINGS #
############

# Lines configured by zsh-newuser-install
setopt notify
bindkey -v
bindkey -v '^?' backward-delete-char
# lower the delay after hitting the <ESC> key to 0.1s
export KEYTIMEOUT=1
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ryan/.zshrc'

# Turn on global append and shared history
# https://askubuntu.com/questions/23630/how-do-you-share-history-between-terminals-in-zsh
setopt inc_append_history
setopt share_history
export HISTSIZE=10000


# turns on command substitution in the prompt
setopt PROMPT_SUBST

# will silently pass "*" through to the underlying command when there are no
# matches
setopt rm_star_silent

# https://dougblack.io/words/zsh-vi-mode.html
#function zle-line-init zle-keymap-select {
#  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
#  RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $(git_custom_status) $EPS1"
#  zle reset-prompt
#}
# Note the single quotes
export RPS1='${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}${MODE_INDICATOR_PROMPT} ${vcs_info_msg_0_}'
