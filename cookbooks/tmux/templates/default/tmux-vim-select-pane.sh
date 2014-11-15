#!/usr/bin/env bash

set -e

direction=$(echo "${1#-}" | sed -e 's/D/Down/' -e 's/U/Up/' -e 's/L/Left/' -e 's/R/Right/');

if tmux display -p '#{pane_current_command}' | grep -iqE '(^|\/)g?(view|n?vim?)(diff)?$'; then
  tmux send-keys C-$direction
elif [[ $direction == "Left" ]]; then
  tmux previous-window
elif [[ $direction == "Right" ]]; then
  tmux next-window
else
  tmux select-pane "$@"
fi
