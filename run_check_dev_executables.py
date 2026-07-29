#!/usr/bin/env python3

import ctypes
import multiprocessing as mp
from concurrent.futures import ThreadPoolExecutor
from subprocess import run
from textwrap import indent

programs = {
    "awk --version": "GNU Awk 5",
    "btop --version": None,
    "chezmoi --version": None,
    "curl --version": "curl 8",
    "delta --version": None,
    "fd --version": "fd 10",
    "fish --version": "fish, version 4",
    "forge version": "forge 0.5",
    "fzf --version": "0.72.0",
    "git --version": "git version 2",
    "grep --version": "grep (GNU grep) 3",
    "jq --version": "jq-1",
    "lazy-tmux version": "lazy-tmux 0.2",
    "make --version": "GNU Make 4",
    "mise --version": None,
    "nvim --version": "NVIM v0.12.3",
    "rg --version": "ripgrep 15",
    "sed --version": "sed (GNU sed) 4",
    "tmux -V": "tmux 3.6b",
    "tpm": None,
    "xh --version": "xh 0.26",
    "yq --version": "yq (https://github.com/mikefarah/yq/) version v4",
}

missing = mp.Value(ctypes.c_uint, 0)
bad_version = mp.Value(ctypes.c_uint, 0)

def check_program(program: str, expected_version: str | None) -> None:
    global missing, bad_version
    proc = run(program, shell=True, capture_output=True, text=True)
    if proc.returncode != 0:
        print(f"Error running '{program}':")
        print(indent(proc.stderr.strip(), "  "))
        with missing.get_lock():
            missing.value += 1
    if expected_version is not None and expected_version not in proc.stdout:
        print(f"'{program}' did not match expected version '{expected_version}':")
        print(indent(proc.stdout.strip(), "  "))
        with bad_version.get_lock():
            bad_version.value += 1

with ThreadPoolExecutor() as executor:
    for program, expected_version in programs.items():
        executor.submit(check_program, program, expected_version)

print(f"\nSummary: {missing.value} missing programs, {bad_version.value} version mismatches.")
