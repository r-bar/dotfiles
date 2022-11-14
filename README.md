# Home Folder and Personal Configuration Files

Configuration files are primarily geared toward Python, Rust, and more generally
web application development.

## Requirements
* [yadm](https://yadm.io/)
* [git-crypt](https://github.com/AGWA/git-crypt) required to read /
  modify encrypted files

## Cloning
```
yadm clone --recursive git@github.com:r-bar/dotfiles.git
base64 -d base64.txt | yadm git-crypt unlock -
```

Bootstrap without an authorized ssh key:
```
yadm clone git@github.com:r-bar/dotfiles.git
base64 -d base64.txt | yadm git-crypt unlock -
git remote set-url origin git@github.com:r-bar/dotfiles.git
```

## Refresh submodules
```
yadm submodule update
```
