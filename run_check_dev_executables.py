#!/usr/bin/env python3
"""Script for checking the presence and versions of development executables on the system.

Must be compatible with python >= 3.9
"""
import os
import sys
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed

if source_dir := os.environ.get("CHEZMOI_SOURCE_DIR"):
    sys.path.insert(0, source_dir)

from lib.prog_check import (
    check_program,
    Program,
    Brew,
    Apt,
    Pacman,
    BadVersionError,
    ProgramNotFoundError,
    CheckError,
)


PROGRAMS = (
    Program(
        "awk --version",
        version="GNU Awk 5",
        sources=[Brew("gawk"), Apt("awk"), Pacman("awk")],
    ),
    Program(
        "btop --version",
        version="btop version: 1",
        sources=[Brew("btop"), Apt("btop"), Pacman("btop")],
    ),
    Program(
        "bwrap --version",
        version="0.11",
        sources=[Pacman("bubblewrap"), Apt("bubblewrap")],
    ),
    Program(
        "chezmoi --version",
        version="chezmoi version v2",
        sources=[Brew("chezmoi"), Apt("chezmoi"), Pacman("chezmoi")],
    ),
    Program(
        "curl --version",
        version="curl 8",
        sources=[Brew("curl"), Apt("curl"), Pacman("curl")],
    ),
    Program(
        "delta --version",
        version="delta 0.19",
        sources=[Brew("git-delta"), Apt("git-delta"), Pacman("git-delta")],
    ),
    Program(
        "eza --version",
        version="v0.23",
        sources=[Brew("eza"), Pacman("eza")],
    ),
    Program(
        "fd --version",
        version="fd 10",
        sources=[Brew("fd"), Apt("fd-find"), Pacman("fd")],
    ),
    Program(
        "fish --version",
        version="fish, version 4",
        sources=[Brew("fish"), Apt("fish"), Pacman("fish")],
    ),
    Program(
        "forge version",
        version="forge 0.5",
        sources=[Brew("forge"), Apt("forge"), Pacman("forge")],
    ),
    Program(
        "fzf --version",
        version="0.74",
        sources=[Brew("fzf"), Apt("fzf"), Pacman("fzf")],
    ),
    Program(
        "git --version",
        version="git version 2",
        sources=[Brew("git"), Apt("git"), Pacman("git")],
    ),
    Program(
        "grep --version",
        version="grep (GNU grep) 3",
        sources=[Brew("grep"), Apt("grep"), Pacman("grep")],
    ),
    Program(
        "jq --version", version="jq-1", sources=[Brew("jq"), Apt("jq"), Pacman("jq")]
    ),
    Program(
        "lazy-tmux version",
        version="lazy-tmux 0.2",
        sources=[Brew("lazy-tmux"), Apt("lazy-tmux"), Pacman("lazy-tmux")],
    ),
    Program(
        "make --version",
        version="GNU Make 4",
        sources=[Brew("make"), Apt("make"), Pacman("make")],
    ),
    Program("mise --version", sources=[Brew("mise"), Apt("mise"), Pacman("mise")]),
    Program(
        "nvim --version",
        version="NVIM v0.12",
        sources=[Brew("neovim"), Apt("neovim"), Pacman("neovim")],
    ),
    Program(
        "rg --version",
        version="ripgrep 15",
        sources=[Brew("ripgrep"), Apt("ripgrep"), Pacman("ripgrep")],
    ),
    Program(
        "rustup --version",
        version="rustup 1",
        sources=[Brew("rustup"), Apt("rustup"), Pacman("rustup")],
    ),
    Program(
        "sed --version",
        version="sed (GNU sed) 4",
        sources=[Brew("gnu-sed"), Apt("sed"), Pacman("sed")],
    ),
    Program(
        "tmux -V",
        version="tmux 3",
        sources=[Brew("tmux"), Apt("tmux"), Pacman("tmux")],
    ),
    Program(
        "xh --version", version="xh 0.26", sources=[Brew("xh"), Apt("xh"), Pacman("xh")]
    ),
    Program(
        "yq --version",
        version="yq (https://github.com/mikefarah/yq/) version v4",
        sources=[Brew("yq"), Apt("yq"), Pacman("go-yq")],
    ),
)


def main():
    errors = Counter()
    futures = set()

    with ThreadPoolExecutor() as executor:
        for program in PROGRAMS:
            f = executor.submit(check_program, program)
            futures.add(f)
        for result in as_completed(futures):
            try:
                result.result()
            except (BadVersionError, ProgramNotFoundError, CheckError) as e:
                errors[type(e)] += 1
                print(e)

    if errors:
        good_count = len(PROGRAMS) - sum(errors.values())
        summary = ", ".join(f"{count} {t.__name__}" for t, count in errors.items())
        summary += (
            f", {good_count} programs are present and have the expected versions."
        )
    else:
        summary = (
            f"All {len(PROGRAMS)} programs are present and have the expected versions."
        )

    print("\nSummary:", summary)


if __name__ == "__main__":
    main()
