#!/bin/bash


SOURCE=${BASH_SOURCE[0]}
# resolve $SOURCE until the file is no longer a symlink
while [ -L "$SOURCE" ]; do
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  # if $SOURCE was a relative symlink, we need to resolve it relative to the
  # path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

if ! hash python3 2> /dev/null; then
  echo "Python 3 is required to install packages"
  exit 1
fi

if [ ! -d $DIR/venv ]; then
    echo "Creating bootstrap environment..."
    python3 -m venv $DIR/venv
    mkdir -p $DIR/venv/ansible/{roles,library}
fi
VIRTUAL_ENV=$DIR/venv
PATH=$VIRTUAL_ENV/bin:$PATH

cd $DIR

REQUIREMENTS_CHECKSUM="$(sha256sum requirements.txt)"
CACHED_CHECKSUM="$(cat $VIRTUAL_ENV/requirements.txt.checksum 2> /dev/null)"

if [ "$REQUIREMENTS_CHECKSUM" != "$CACHED_CHECKSUM" ]; then
    echo Requirements have changed, installing...
    pip install -r requirements.txt
    ansible-galaxy install jpedrodelacerda.yay -p $VIRTUAL_ENV/ansible/roles
    curl -sLf https://github.com/mnussbaum/ansible-yay/raw/4fd5ec87f3c3ec5366376b30317714fee7e20b06/yay \
      -o $VIRTUAL_ENV/ansible/library/yay
    echo "$REQUIREMENTS_CHECKSUM" > $VIRTUAL_ENV/requirements.txt.checksum
fi

ansible-playbook install.yml --ask-become-pass
