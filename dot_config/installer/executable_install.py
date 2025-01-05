#!/usr/bin/env python3

import logging
import sys
import os
import shutil
import argparse
from dataclasses import dataclass, asdict
from hashlib import sha256
from pathlib import Path
from typing import Iterable
from subprocess import run
from abc import ABC, abstractmethod


DIR = Path(__file__).resolve().parent
VIRTUAL_ENV = DIR / "venv"
REQUIREMENTS_FILE = DIR / "requirements.txt"
INSTALLED_CHECKSUM_FILE = VIRTUAL_ENV / "requirements.txt.checksum"
PACKAGES_FILE = DIR / "packages.yml"


@dataclass
class PackageDef:
    name: str
    description: str | None = None
    apt: str | bool = True
    yay: str | bool = True
    flatpak: str | bool = False
    tags: list[str] | None = None


def package_str(s: str | None) -> bool | str | None:
    if s is None:
        return None
    if s.lower() == "true":
        return True
    if s.lower() == "false":
        return False
    return s


class Cli:
    def __init__(self, argv=sys.argv[1:]):
        p = argparse.ArgumentParser(description="Manage dotfile package registry")
        p.add_argument(
            "--relaunched", action="store_true", help=argparse.SUPPRESS, default=False
        )
        p.add_argument(
            "-v", "--verbose", action="store_true", help="Enable verbose output"
        )
        sub = p.add_subparsers(dest="command")
        cmd_sync = sub.add_parser("sync", help=command_sync.__doc__)
        cmd_sync.add_argument(
            "--reinstall", action="store_true", help="Reinstall all tracked packages"
        )
        cmd_sync.add_argument(
            "--no-update-cache",
            action="store_false",
            dest="update_cache",
            help="Do not update the package cache",
        )
        cmd_sync.add_argument(
            "--dry-run", action="store_true", help="Do not install packages"
        )
        cmd_add = sub.add_parser("add", help=command_add.__doc__)
        cmd_add.add_argument("package", help="Package to add")
        cmd_add.add_argument(
            "-s",
            "--sync",
            action="store_true",
            help="Sync packages after adding new package",
        )
        cmd_add.add_argument(
            "-t",
            "--tag",
            action="append",
            dest="tags",
            help="Add a tag to the package. Can be specified multiple times.",
        )
        cmd_add.add_argument("-d", "--description", help="Description of the package")
        cmd_add.add_argument(
            "-a", "--apt", help="APT package name", metavar="PKG", type=package_str
        )
        cmd_add.add_argument(
            "-y",
            "--yay",
            help="Archlinux / AUR package name",
            metavar="PKG",
            type=package_str,
        )
        cmd_add.add_argument(
            "-f",
            "--flatpak",
            help="Flatpak package name",
            metavar="PKG",
            type=package_str,
        )
        cmd_list = sub.add_parser("list", help=command_list.__doc__)  # noqa
        cmd_list.add_argument(
            "-n",
            "--no-show-package-def",
            dest="show_package_def",
            action="store_false",
            help="Do not show package definitions",
        )
        cmd_fmt = sub.add_parser("fmt", help=command_format.__doc__)  # noqa
        cmd_remove = sub.add_parser("remove", help=command_remove.__doc__)
        cmd_remove.add_argument("package", help="Package to remove")
        cmd_remove.add_argument(
            "-u",
            "--uninstall",
            action="store_true",
            help="Uninstall the package after removing it from the package list",
        )
        sub_tag_add = sub.add_parser("tag-add", help=command_tag_add.__doc__)
        sub_tag_add.add_argument("tag", help="The tag to add")
        sub_tag_add.add_argument(
            "-i", "--install", action="store_true", help="Install packages for this tag"
        )
        sub_tag_remove = sub.add_parser("tag-remove", help=command_tag_remove.__doc__)
        sub_tag_remove.add_argument("tag", help="The tag to remove")
        sub_tag_remove.add_argument(
            "-i", "--install", action="store_true", help="Install packages for this tag"
        )
        sub_tag_list = sub.add_parser("tag-list", help=command_tag_list.__doc__)  # noqa

        self.parser = p
        self.args = p.parse_args(argv)

        self.command = None
        for k, v in vars(self.args).items():
            setattr(self, k, v)

        if self.verbose:
            logging.basicConfig(level=logging.DEBUG)
        else:
            logging.basicConfig(level=logging.INFO)

    def package_def(self) -> PackageDef:
        try:
            package = {"name": self.package}
        except AttributeError:
            raise ValueError("package_def is not available for this command")
        arg_names = PackageDef.__annotations__.keys()
        for arg in arg_names:
            value = getattr(self.args, arg, None)
            if value is not None:
                package[arg] = value
        return PackageDef(**package)


class PackageRegistry:
    def __init__(self, path: Path):
        from ruamel.yaml import YAML

        self.path = path
        self.serializer = YAML()
        self.data = self.serializer.load(path)
        self.changed = False

    def add_package(
        self,
        package: PackageDef,
        update: bool = True,
    ) -> None:
        self.changed = True
        existing = self.data["packages"].get(package.name, {})
        data = {k: v for k, v in asdict(package).items() if v is not False}
        name = data.pop("name")
        if update:
            data = existing | data
        self.data["packages"][name] = data

    def remove_package(self, package: str) -> None:
        self.changed = True
        del self.data["packages"][package]

    def add_tag(self, machine: str, tag: str) -> None:
        self.changed = True
        if machine not in self.data["machine_tags"]:
            self.data["machine_tags"][machine] = [tag]
        else:
            self.data["machine_tags"][machine].append(machine)

    def remove_tag(self, machine: str, tag: str) -> None:
        self.changed = True
        if machine not in self.data["machine_tags"]:
            return
        tags = set(self.data["machine_tags"][machine])
        tags -= {tag}
        if not tags:
            del self.data["machine_tags"][machine]
        else:
            self.data["machine_tags"][machine] = sorted(tags)

    def packages(
        self,
        installer: str | None = None,
        machine_tags: Iterable[str] | None = None,
        for_tag: str | None = None,
    ) -> Iterable[PackageDef]:
        """Return a list of package defs for the given selectors"""
        if machine_tags and for_tag:
            raise ValueError("Cannot specify both machine_tags and for_tag")
        machine_tags = set() if machine_tags is None else set(machine_tags)
        for package, package_def in self.data["packages"].items():
            package_def = PackageDef(name=package, **package_def)
            selected = True
            if machine_tags and package_def.tags:
                selected = selected and any(t in machine_tags for t in package_def.tags)
            elif for_tag and package_def.tags:
                selected = selected and for_tag in package_def.tags
            elif for_tag and not package_def.tags:
                selected = False
            if installer:
                selected = selected and getattr(package_def, installer) is not False
            if selected:
                yield package_def

    def machine_tags(self, machine: str) -> list[str]:
        return self.data["machine_tags"].get(machine, [])

    def save(self) -> None:
        """Save the data to the file if it has changed."""
        if not self.changed:
            return
        ordered_machine_tags = dict(sorted(self.data["machine_tags"].items()))
        ordered_packages = dict(sorted(self.data["packages"].items()))
        self.data["machine_tags"] = ordered_machine_tags
        self.data["packages"] = ordered_packages
        with open(self.path, "w") as f:
            self.serializer.dump(self.data, f)
            self.changed = False


class PackageManager(ABC):
    package_managers = []

    def __init_subclass__(cls, **kwargs):
        cls.package_managers.append(cls)

    @classmethod
    def first_usable(cls) -> "PackageManager":
        for pm in cls.package_managers:
            if pm.usable():
                return pm()
        raise ValueError("No usable package manager found.")

    @classmethod
    def all_usable(cls) -> list["PackageManager"]:
        return [pm() for pm in cls.package_managers if pm.usable()]

    @classmethod
    def package_name(cls, package_def: PackageDef) -> str | None:
        explicit = getattr(package_def, cls.key)
        if explicit is False:
            return None
        return getattr(package_def, cls.key) or package_def.name

    def resolve_package_names(
        self, packages: list[PackageDef], reinstall=False
    ) -> list[str]:
        package_names = []
        for package in packages:
            if package_name := self.package_name(package):
                package_names.append(package_name)
        if not reinstall:
            installed = self.list()
            package_names = [p for p in package_names if p not in installed]
        return package_names

    @classmethod
    @property
    @abstractmethod
    def key(cls) -> str:
        raise NotImplementedError

    @abstractmethod
    def install(
        self, package: list[str], update_cache=True, reinstall=False, dry_run=False
    ) -> None:
        raise NotImplementedError

    @abstractmethod
    def uninstall(self, package: list[str]) -> None:
        raise NotImplementedError

    @abstractmethod
    def list(self) -> bool:
        raise NotImplementedError

    @classmethod
    @abstractmethod
    def usable(self) -> bool:
        raise NotImplementedError


class Yay(PackageManager):
    key = "yay"

    def install(
        self,
        packages: list[PackageDef],
        update_cache=True,
        reinstall=False,
        dry_run=False,
    ) -> None:
        package_names = self.resolve_package_names(packages, reinstall)
        sub = "-Sy" if update_cache else "-S"
        cmd = ["yay", sub, "--noconfirm", *package_names]
        if dry_run:
            print("dry run:", *cmd)
        run(cmd, check=True)

    def uninstall(self, packages: list[str]) -> None:
        run(["yay", "-R", "--noconfirm", *packages], check=True)

    def list(self) -> list[str]:
        proc = run(["yay", "-Qent"], check=True, capture_output=True, text=True)
        lines = proc.stdout.splitlines()
        return [line.split()[0] for line in lines]

    @classmethod
    def usable(cls) -> bool:
        return shutil.which("yay") is not None


class Flatpak(PackageManager):
    key = "flatpak"

    def install(
        self,
        packages: list[PackageDef],
        update_cache=True,
        reinstall=False,
        dry_run=False,
    ) -> None:
        package_names = self.resolve_package_names(packages, reinstall)
        cmd = ["flatpak", "install", "-y", *package_names]
        if dry_run:
            print("dry run:", *cmd)
        run(cmd, check=True)

    def uninstall(self, packages: list[str]) -> None:
        run(["flatpak", "uninstall", *packages], check=True)

    def list(self) -> list[str]:
        proc = run(
            ["flatpak", "list", "--app", "--columns=application"],
            check=True,
            capture_output=True,
            text=True,
        )
        lines = proc.stdout.splitlines()
        return [line.strip() for line in lines[1:]]

    @classmethod
    def usable(cls) -> bool:
        return shutil.which("flatpak") is not None


def hostname() -> str:
    if hostname := os.environ.get("HOSTNAME"):
        return hostname
    elif Path("/etc/hostname").exists():
        with open("/etc/hostname") as f:
            return f.read().strip()
    else:
        return "localhost"


def command_sync(
    update_cache: bool = True,
    reinstall: bool = False,
    registry: PackageRegistry | None = None,
    pms: list[PackageManager] | None = None,
    packages: list[PackageDef] | None = None,
    dry_run: bool = False,
) -> None:
    """Install all packages in the packages file"""
    registry = registry or PackageRegistry(PACKAGES_FILE)
    pms = pms or PackageManager.all_usable()
    machine_tags = registry.machine_tags(hostname())
    packages = packages or registry.packages(machine_tags=machine_tags)
    for pm in pms:
        pm_packages = (pm.package_name(p) for p in packages)
        pm_packages = [p for p in pm_packages if p is not None]
        pm.install(
            pm_packages, update_cache=update_cache, reinstall=reinstall, dry_run=dry_run
        )


def command_add(package_def: PackageDef, install=False) -> None:
    """Add a package to the packages file"""
    package_def = package_def or {}
    registry = PackageRegistry(PACKAGES_FILE)
    registry.add_package(package_def)
    registry.save()
    if install:
        command_sync(packages=[package_def["name"]], registry=registry)


def command_remove(
    package: str, uninstall: bool = True, pm: PackageManager | None = None
) -> None:
    """Remove a package from the packages file"""
    registry = PackageRegistry(PACKAGES_FILE)
    registry.remove_package(package)
    registry.save()
    if uninstall:
        pm = pm or PackageManager.first_usable()
        pm.uninstall([package])


def command_list(
    show_package_def: bool = True,
    registry: PackageRegistry | None = None,
    pms: list[PackageManager] | None = None,
):
    """List all packages in the packages file"""
    registry = registry or PackageRegistry(PACKAGES_FILE)
    for package_def in registry.packages():
        print(package_def["name"])
        if show_package_def:
            for key, value in package_def.items():
                if key == "name":
                    continue
                print(f"  {key}: {value}")


def command_format():
    """Format the packages file"""
    registry = PackageRegistry(PACKAGES_FILE)
    registry.changed = True
    registry.save()


def command_tag_add(hostname: str, tag: str, install: bool = False):
    """Add a tag to the current machine"""
    registry = PackageRegistry(PACKAGES_FILE)
    registry.add_tag(hostname, tag)
    registry.save()
    if install:
        command_sync()


def command_tag_remove(
    hostname: str, tag: str, uninstall: bool = False, pm: PackageManager | None = None
):
    """Remove a tag from the current machine"""
    registry = PackageRegistry(PACKAGES_FILE)
    registry.remove_tag(hostname, tag)
    registry.save()
    if uninstall:
        pm = pm or PackageManager.first_usable()
        packages = registry.packages(pm.key, [tag])
        pm.uninstall(packages)


def command_tag_list(cli: Cli):
    """List machine tags for the current machine"""
    registry = PackageRegistry(PACKAGES_FILE)
    tags = registry.machine_tags(hostname())
    for tag in tags:
        print(tag)


def bootstrap(relaunched: bool) -> None:
    """Bootstrap our own environment"""
    if sys.version_info < (3, 10):
        raise ValueError("Python 3.10 or later is required")
    if not (DIR / "venv").exists():
        run([sys.executable, "-m", "venv", VIRTUAL_ENV], check=True)
    venv_sys_path = (
        VIRTUAL_ENV
        / "lib"
        / f"python{sys.version_info.major}.{sys.version_info.minor}"
        / "site-packages"
    )
    with open(REQUIREMENTS_FILE) as f:
        requirements_checksum = sha256(f.read().encode()).hexdigest()
    with open(INSTALLED_CHECKSUM_FILE) as f:
        installed_checksum = f.read().strip()
    if requirements_checksum != installed_checksum:
        pip = str(DIR / "venv" / "bin" / "pip")
        run([pip, "install", "-r", REQUIREMENTS_FILE], check=True)
        with open(INSTALLED_CHECKSUM_FILE, "w") as f:
            f.write(requirements_checksum)

    if str(venv_sys_path) not in sys.path:
        if relaunched:
            print("Failed to relaunch in virtual environment", file=sys.stderr)
            print(f"{sys.path=}")
            print(f"{sys.executable=}")
            print(f"{os.environ.get('VIRTUAL_ENV')=}")
            exit(1)
        python = VIRTUAL_ENV / "bin" / "python"
        proc = run(
            [python, __file__, "--relaunched", *sys.argv[1:]],
        )
        exit(proc.returncode)

    return


def main():
    cli = Cli()
    bootstrap(cli.relaunched)
    match cli.command:
        case "sync":
            command_sync(
                update_cache=cli.update_cache,
                reinstall=cli.reinstall,
                dry_run=cli.dry_run,
            )
        case "add":
            command_add(cli.package_def(), cli.sync)
        case "remove":
            command_remove(cli.package, uninstall=cli.uninstall)
        case "list":
            command_list(show_package_def=cli.show_package_def)
        case "fmt":
            command_format()
        case "tag-add":
            command_tag_add(cli)
        case "tag-remove":
            command_tag_remove(cli)
        case "tag-list":
            command_tag_list(cli)
        case _:
            print(f"Undefined command `{cli.command}`", file=sys.stderr)
            exit(1)


if __name__ == "__main__":
    main()
