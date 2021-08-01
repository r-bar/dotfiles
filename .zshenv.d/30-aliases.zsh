# aliases available in non-interactive mode
alias gconfig='gcloud config configurations'
alias gr='cd ./$(git rev-parse --show-cdup)'
alias strip-escape='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'
