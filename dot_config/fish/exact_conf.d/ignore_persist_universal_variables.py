#!/usr/bin/env python3

from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from enum import StrEnum
from hashlib import sha256
from pathlib import Path
import re
from shutil import which
from subprocess import run


NAME_FILTERS = (
    r"_fisher_.*",
    r"tide_.*",
)


CONFIG_LINE = re.compile(r"^\$(\w+): set in (\w+) scope, (exported|unexported), (|a path variable )with (\d+) elements(| \(read-only\))$")
VALUE_LINE = re.compile(r"^\$(\w+)\[(\d+)\]: \|(.*)\|$")
INHERITED_LINE = re.compile(r"^\$(\w+): originally inherited as \|(.*)\|$")
CONFIG_FILE = Path(__file__).parent.joinpath(
    Path(__file__).name.replace(".py", ".fish").removeprefix("ignore_")
)


class Scope(StrEnum):
    LOCAL = "local"
    GLOBAL = "global"
    UNIVERSAL = "universal"


@dataclass
class FishVariable:
    name: str
    values: list[str]
    scope: Scope
    exported: bool
    path: bool

    def value(self) -> str:
        return " ".join(self.values)

    def set_command(self) -> str:
        flags = [f"-{self.scope.value[:1]}"]
        if self.exported:
            flags.append("-x")
        if self.path:
            flags.append("--path")
        flag_str = " ".join(flags)
        values = " ".join(quote(v) for v in self.values)
        return f"set {flag_str} {quote(self.name)} {values}"

    def match(
        self,
        *,
        name_filter: re.Pattern = re.compile(r".*"),
        scope_filter: Sequence[Scope] = tuple(Scope),
    ) -> bool:
        if self.scope not in scope_filter:
            return False
        return name_filter.match(self.name) is not None

    @classmethod
    def parse(cls, set_s_output: str) -> Iterable["FishVariable"]:
        """Parse FishVariables from the output of """
        vars = []
        var = FishVariable(
            name="",
            values=[],
            scope=Scope.LOCAL,
            exported=False,
            path=False,
        )
        num_elements = -1
        last_num_elements = -1

        for line in set_s_output.splitlines():
            if match := CONFIG_LINE.match(line):
                name, scope, visibility, path_var, num_elements, *_ = match.groups()
                # check if name has a value to determine if this is the first time
                # through the loop
                if var.name and len(var.values) != last_num_elements:
                    raise Exception(f"Corruped variable data, length did not match {len(var.values)} != {last_num_elements}")
                last_num_elements = int(num_elements)
                var = FishVariable(
                    name=name,
                    values=[],
                    scope=Scope(scope),
                    exported=(visibility == "exported"),
                    path=path_var != "",
                )
                vars.append(var)

            elif match := VALUE_LINE.match(line):
                val_name, val_num, value = match.groups()
                assert var.name == name, f"Name mismatch: {name} != {var.name}"
                assert int(val_num) <= last_num_elements
                var.values.append(value)

            elif match := INHERITED_LINE.match(line):
                val_name, value = match.groups()
                assert var.name == name, f"Name mismatch: {name} != {var.name}"
                continue

            else:
                raise Exception(f"Unrecognized line format: {line.strip()}")

        return vars


def quote(s: str) -> str:
    escaped = s.replace('"', r'\"')
    return f'"{escaped}"'


def get_fish_variables() -> str | None:
    fish = which("fish")
    if fish is None:
        return None
    proc = run([fish, "-c", "set -S"], text=True, check=True, capture_output=True)
    return proc.stdout


def main():
    name_filter = re.compile(f"^({'|'.join(NAME_FILTERS)})$")
    scope_filter = [Scope.UNIVERSAL]

    raw_vars = get_fish_variables()
    if raw_vars is None:
        return

    vars = FishVariable.parse(raw_vars)

    updated = "\n".join(
        var.set_command() for var in vars
        if var.match(name_filter=name_filter, scope_filter=scope_filter)
    )
    updated_hash = sha256(updated.encode())
    try:
        with open(CONFIG_FILE, 'rb') as f:
            existing_hash = sha256(f.read())
    except FileNotFoundError:
        print("warning: No existing config file found, creating new one.")
        existing_hash = sha256(b"")  # No existing file means no hash

    if existing_hash.digest() == updated_hash.digest():
        print("No changes to persisted universal variables.")
        exit(0)
    else:
        with open(CONFIG_FILE, 'w') as f:
            f.write(updated)
        print(f'Updated persisted universal variables to {CONFIG_FILE}')
        exit(1)


if __name__ == "__main__":
    main()
