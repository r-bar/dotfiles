if [[ ! -d ~/.local/share/zigup ]]; then
  mkdir -p ~/.local/share/zigup
fi

alias zigup='zigup --install-dir ~/.local/share/zigup --path-link /usr/local/bin/zig'
