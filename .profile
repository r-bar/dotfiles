# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
# Lima BEGIN
# Make sure iptables and mount.fuse3 are available
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/sbin:/sbin"
# fuse-overlayfs is the most stable snapshotter for rootless
CONTAINERD_SNAPSHOTTER="fuse-overlayfs"
export PATH CONTAINERD_SNAPSHOTTER
# Lima END
if [ -e /home/ryanbarth.linux/.nix-profile/etc/profile.d/nix.sh ]; then . /home/ryanbarth.linux/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
