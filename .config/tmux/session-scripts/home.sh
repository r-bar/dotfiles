#!/bin/zsh

SESSION_NAME="home"
tmux has-session -t $SESSION_NAME &> /dev/null

if [ $? != 0 ]; then
  tmux new-session -s $SESSION_NAME -n "home" -d
  tmux move-window -s $SESSION_NAME:1 -t $SESSION_NAME:0
  tmux new-window -t $SESSION_NAME:1 -n "infra" -c ~/src/infra
  tmux new-window -t $SESSION_NAME:2 -n "game" -c ~/src/game/game-zig
  tmux kill-window -t $SESSION_NAME:0
fi

if [ -n "$TMUX" ]; then
  tmux switch-client -t $SESSION_NAME
else
  tmux attach -t $SESSION_NAME
fi
