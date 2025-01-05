# Home Folder and Personal Configuration Files

Configuration files are primarily geared toward Python, Rust, and more generally
web application development.

## Requirements
* [chezmoi](https://www.chezmoi.io/) configuration manager.
* [Bitwarden CLI](https://github.com/bitwarden/clients) password manager. Used
to provide the decryption key.

## Usage
```bash
BW_SESSION=$(bw login <email> --raw) chezmoi init --apply r-bar
```
