ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
if [ ! -d $ZINIT_HOME/.git ]; then
  echo Initializing zinit...
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

#zinit ice depth=1;
#zinit light romkatv/zsh-prompt-benchmark
zinit ice depth=1; zinit light z-shell/F-Sy-H # syntax highlighting
zinit ice depth=1; zinit light zsh-users/zsh-completions
zinit ice depth=1; zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light Tarrasch/zsh-command-not-found
zinit ice depth=1; zinit light zpm-zsh/ssh
zinit ice depth=1; zinit light romkatv/powerlevel10k
