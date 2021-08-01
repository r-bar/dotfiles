define PRE_COMMIT_CONTENT
#!/bin/bash

# https://stackoverflow.com/a/246128
SOURCE="$${BASH_SOURCE[0]}"
while [ -h "$$SOURCE" ]; do # resolve $$SOURCE until the file is no longer a symlink
  DIR="$$( cd -P "$$( dirname "$$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$$(readlink "$$SOURCE")"
  [[ $$SOURCE != /* ]] && SOURCE="$$DIR/$$SOURCE" # if $$SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$$( cd -P "$$( dirname "$$SOURCE" )" >/dev/null 2>&1 && pwd )"

bash $$DIR/pre-commit-crypt
python $$DIR/pre-commit.py
endef

.PHONY: transcrypt
transcrypt: repo.git/hooks/pre-commit-crypt
repo.git/hooks/pre-commit-crypt:
	mkdir /tmp/fake-repo && cd /tmp/fake-repo \
		&& git init \
		&& cp -r .git .git.bak \
		&& transcrypt \
		&& diff -rN .git.bak .git > transcrypt.patch
	patch -s -p0 repo.git /tmp/fake-repo/transcrypt.patch
	rm -rf /tmp/fake-repo

repo.git/hooks/pre-commit.py:
	mkdir /tmp/fake-repo && cd /tmp/fake-repo \
		&& git init \
		&& cp -r .git .git.bak \
		&& pre-commit install \
		&& mv .git/hooks/pre-commit .git/hooks/pre-commit.py
		&& diff -rN .git.bak .git > pre-commit.patch
	patch -s -p0 repo.git /tmp/fake-repo/pre-commit.patch
	rm -rf /tmp/fake-repo

.PHONY: pre-commit
pre-commit: repo.git/hooks/pre-commit
repo.git/hooks/pre-commit: repo.git/gooks/pre-commit-crypt repo.git/hooks/pre-commit.py
	echo "$$PRE_COMMIT_CONTENT" > $@


.PHONY: clean-hooks
clean-hooks:
	rm -f repo.git/crypt
	rm -f repo.git/hooks/{pre-commit,pre-commit-crypt,pre-commit.py}
