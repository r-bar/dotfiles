import ctypes
import dataclasses as dc
import re
import typing as t
from abc import ABC, abstractmethod
from collections import abc, Counter
from shutil import which
from subprocess import run
from textwrap import indent
from threading import Lock


# https://stackoverflow.com/questions/14693701/how-can-i-remove-the-ansi-escape-sequences-from-a-string-in-python
ansi_escape = re.compile(
    r"""
    \x1B  # ESC
    (?:   # 7-bit C1 Fe (except CSI)
        [@-Z\\-_]
    |     # or [ for CSI, followed by a control sequence
        \[
        [0-?]*  # Parameter bytes
        [ -/]*  # Intermediate bytes
        [@-~]   # Final byte
    )
""",
    re.VERBOSE,
)


class Source:
    executable: abc.Sequence[str]

    def version(self) -> t.Optional[str]:
        proc = run([*self.executable, "--version"], text=True, capture_output=True)
        if proc.returncode != 0:
            return None
        return proc.stdout.strip()

    @abstractmethod
    def update_all(self) -> None: ...

    @abstractmethod
    def install(self, packages: abc.Sequence[str]) -> None: ...


@dc.dataclass
class Brew(Source):
    package: t.Union[str, abc.Set[str]]

    executable: abc.Sequence[str] = "brew"

    def update_all(self) -> None:
        run([*self.executable, "update"], check=True)
        run([*self.executable, "upgrade", "-y"], check=True)

    def install(self, packages: abc.Sequence[str]) -> None:
        cmd = [*self.executable, "install", "-y", *packages]
        run(cmd, check=True)


@dc.dataclass
class Apt(Source):
    package: t.Union[str, abc.Set[str]]

    executable: abc.Sequence[str] = "apt-get"

    def install(self, packages: abc.Sequence[str]) -> None:
        cmd = [*self.executable, "install", "-y", *packages]
        run(cmd, check=True)

    def update_all(self) -> None:
        run([*self.executable, "update"], check=True)
        run([*self.executable, "upgrade", "-y"], check=True)


@dc.dataclass
class Pacman(Source):
    package: t.Union[str, abc.Set[str]]

    executable: abc.Sequence[str] = "pacman"

    def install(self, packages: abc.Sequence[str]) -> None:
        cmd = [*self.executable, "-S", "--noconfirm", *packages]
        run(cmd, check=True)

    def update_all(self) -> None:
        run([*self.executable, "-Syu", "--noconfirm"], check=True)


# @dc.dataclass
# class Aur(Source):
#     package: t.Union[str, abc.Set[str]]


@dc.dataclass
class Ubi(Source):
    package: t.Union[str, abc.Set[str]]
    install_options: abc.Sequence[str] = dc.field(default_factory=list)

    executable: abc.Sequence[str] = tuple("mise exec ubi -- ubi".split())

    def install(self, packages: abc.Sequence[str]) -> None:
        for package in packages:
            is_url = package.startswith("http://") or package.startswith("https://")
            package_flag = "--url" if is_url else "--package"
            cmd = [
                *self.executable,
                "install",
                *self.install_options,
                package_flag,
                package,
            ]
            run(cmd, check=True)


@dc.dataclass
class Program:
    check: str
    version: t.Optional[str] = None
    sources: abc.Sequence[Source] = dc.field(default_factory=list)

    def name(self) -> str:
        return self.check.split()[0]

    def __hash__(self) -> int:
        return hash((self.check, self.version))


class Results:
    def __init__(self):
        self.lock = Lock()
        self._missing = []
        self._bad_version = []

    @property
    def missing(self) -> abc.Sequence[Program]:
        return self._missing

    @property
    def bad_version(self) -> abc.Sequence[Program]:
        return self._bad_version

    def add_missing(self, program: Program) -> None:
        with self.lock:
            self._missing.append(program)

    def add_bad_version(self, program: Program) -> None:
        with self.lock:
            self._bad_version.append(program)


class BadVersionError(Exception):
    program: Program
    detected_version: t.Optional[str]

    def __init__(self, program: Program, detected_version: t.Optional[str]) -> None:
        self.program = program
        self.detected_version = detected_version
        super().__init__(
            f"Program '{program.name()}' has version mismatch: expected '{program.version}', detected '{detected_version}'."
        )

    def __str__(self) -> str:
        clsname = type(self).__name__
        s = f"{clsname}: Version mismatch for {self.program.name()}:\n"
        s += f"  Expected version: {self.program.version}\n"
        s += "  Detected version:\n"
        s += indent(self.detected_version or "", "    ")
        return s


class CheckError(Exception):
    program: Program
    error: str

    def __init__(self, program: Program, error: str) -> None:
        self.program = program
        self.error = error
        super().__init__(str(self))

    def __str__(self) -> str:
        clsname = type(self).__name__
        s = f"{clsname}: Error running {self.program.name()}:\n"
        s += indent(self.error, "  ")
        return s


class ProgramNotFoundError(Exception):
    program: Program

    def __init__(self, program: Program) -> None:
        self.program = program
        super().__init__(str(self))

    def __str__(self) -> str:
        clsname = type(self).__name__
        s = f"{clsname}: Program '{self.program.name()}' not found in PATH."
        return s


def terminal_clean(s: str) -> str:
    return ansi_escape.sub("", s)


def check_program(program: Program) -> None:
    if not which(program.name()):
        raise ProgramNotFoundError(program)
    proc = run(program.check, shell=True, capture_output=True, text=True)
    if proc.returncode != 0:
        raise CheckError(program, terminal_clean(proc.stderr.strip()))
    clean_stdout = terminal_clean(proc.stdout.strip())
    if program.version is not None and program.version not in clean_stdout:
        raise BadVersionError(program, clean_stdout)
