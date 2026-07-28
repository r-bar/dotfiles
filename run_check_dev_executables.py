#!/usr/bin/env python3

from concurrent.futures import ThreadPoolExecutor
from subprocess import run

programs = {
    "btop --version": None,
    "tmux -V": "tmux 3.6b",
    "nvim --version": "NVIM v0.12.3",
    "delta --version": None,
    "chezmoi --version": None,
    "mise --version": None,
    "tpm": None,
    "fzf --version": "0.72.0",
    "git --version": "git version 2",
    "rg --version": "ripgrep 15",
    "fd --version": "fd 10",
    "fish --version": "fish, version 4",
    "sed --version": "sed (GNU sed) 4",
    "grep --version": "grep (GNU grep) 3",
    "awk --version": "GNU Awk 5",
    "make --version": "GNU Make 4",
    "jq --version": "jq-1",
    "yq --version": "yq (https://github.com/mikefarah/yq/) version v4",
    "forge version": "forge 0.5",
    "lazy-tmux version": "lazy-tmux 0.2",
    "curl": "curl 8.21",
    "xh": "xh 0.26",
}

missing = 0
bad_version = 0

def check_program(program: str, expected_version: str | None) -> None:
    global missing, bad_version
    proc = run(program, shell=True, capture_output=True, text=True)
    if proc.returncode != 0:
        print(f"Error running '{program}': {proc.stderr.strip()}")
        missing += 1
    if expected_version is not None and expected_version not in proc.stdout:
        print(f"Version mismatch for '{program}': expected '{expected_version}', got '{proc.stdout.strip()}'")
        bad_version += 1

with ThreadPoolExecutor() as executor:
    for program, expected_version in programs.items():
        executor.submit(check_program, program, expected_version)

print(f"\nSummary: {missing} missing programs, {bad_version} version mismatches.")
