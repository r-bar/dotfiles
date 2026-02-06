function opencode

  podman run \
    --rm -it \
    -v "$(pwd):$(pwd)" \
    -w "$(pwd)" \
    -v "$HOME/.config/opencode:/root/.config/opencode:ro" \
    -v "$HOME/.cache/opencode:/root/.cache/opencode" \
    -v "$HOME/.local/share/opencode:/root/.local/share/opencode" \
    -v "$HOME/.local/state/opencode:/root/.local/state/opencode" \
    ghcr.io/r-bar/opencode:latest

end
