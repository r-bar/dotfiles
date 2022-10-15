# Home Folder and Personal Configuration Files

Configuration files are primarily geared toward Python, Rust, and more generally
web application development.

## Requirements
* [yadm](https://yadm.io/)
* [transcrypt](https://github.com/r-bar/transcrypt) required to read /
  modify encrypted files

## Cloning
```
yadm clone --recursive git@github.com:r-bar/dotfiles.git
yadm transcrypt -F -c aes-256-cbc:pbkdf2:1024 -p <PASSWORD>
yadm checkout -f # force decryption filters to run
```

Bootstrap without an authorized ssh key:
```
yadm clone git@github.com:r-bar/dotfiles.git
yadm transcrypt -F -c aes-256-cbc:pbkdf2:1024 -p <PASSWORD>
yadm checkout -f # force decryption filters to run
git remote set-url origin git@github.com:r-bar/dotfiles.git
```

## Refresh submodules
```
yadm submodule update
```
