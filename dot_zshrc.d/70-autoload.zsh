fpath+=~/.zfunc
ls -1 ~/.zfunc | while read func; do autoload $func; done
