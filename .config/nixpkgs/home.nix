{ pkgs, config, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  macPkgs = with pkgs; [
    #docker
    #docker-machine
    #docker-machine-hyperkit
    hack-font
    alacritty
  ];

  generalPkgs = with pkgs; [
    gnugrep # requires by direnv-nix on MacOs
    rclone
    tmux
    bat
    pv
    curlie
    ripgrep
    jq
    yq
    remarshal
    yadm
    rename
    gnupg
    htop
  ];

  languagePkgs = with pkgs; [
    rustup
    nodejs
    yarn
  ];

  pythonPkgs = with pkgs; [
    python38
    python38Packages.ipython
    python38Packages.pip
    poetry
  ];

  devtoolsPkgs = with pkgs; [
    universal-ctags
    postgresql
    sqlite
    python38Packages.j2cli
    git
    fd
    watchexec
    exa
    #pyenv # does not exist
    #python-language-server # not supported for darwin
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    nodePackages.ocaml-language-server
    #rust-analyzer
    rust-analyzer-unwrapped
    niv
    kube3d
    #podman # not supported for darwin
    #fuse-overlayfs # not supported for darwin
    #runc # not supported for darwin
    #slirp4netns # not supported for darwin
    #podman-compose # not supported for darwin
    #buildah # not supported for darwin
    hexyl
  ];

  opsPkgs = with pkgs; [
    kubectl
    kubectx
    kubernetes-helm
    #k3s # not supported for darwin
    ansible
    doctl
  ];

in

{
  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  # extra packages without additional configuration
  home.packages = builtins.concatLists [
    generalPkgs
    pythonPkgs
    languagePkgs
    macPkgs
    devtoolsPkgs
    opsPkgs
  ];

  # …
}
