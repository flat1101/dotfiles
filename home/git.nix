{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    git-lfs
  ];
  home.sessionVariables.GIT_EDITOR = config.resources.programs.editor.executable.path;

  programs.git.aliases = {
    a = "apply --index";
    p = "format-patch --stdout";
    tree = "log --graph --pretty=format:'%C(auto)%h - %s [%an] (%C(blue)%ar)%C(auto)%d'";
    bigtree = "log --graph --decorate --pretty=format:'%C(auto)%d%n%h %s%+b%n(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n'";
    hist = "log --date=short --pretty=format:'%C(auto)%ad %h (%G?) %s [%an] %d'";
    xclean = "clean -xdf -e .envrc -e .direnv.* -e shell.nix -e default.nix -e vendor -e .vscode";
  };
  programs.git.enable = true;
  programs.git.extraConfig = ''
    [push]
    default = nothing
    gpgSign = if-asked
    [status]
    short = true
    branch = true
    submoduleSummary = true
    showUntrackedFiles = all
    [color]
    ui = true
    [diff]
    renames = copy
    [branch]
    autosetupmerge = false
    autosetuprebase = always
    [core]
    autocrlf = false
    safecrlf = false
    editor = ${config.resources.programs.editor.executable.path}
    excludesfile = ${builtins.toPath ./../dotfiles/git/gitignore}
    [merge]
    tool = nvimdiff
    conflictstyle = diff3
    [diff]
    tool = nvimdiff
    [mergetool "nvimdiff"]
    cmd = ${pkgs.neovim}/bin/nvim -c "Gdiff" $MERGED
    [format]
    pretty = %C(auto)%h - %s%d%n%+b%+N(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n
    [http]
    cookieFile = ~/.gitcookies
    [http "https://gopkg.in"]
    followRedirects = true
    [filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
    [rerere]
    enabled = true
    [ghq]
    root = ~/src
    [ghq "https://go.thethings.network"]
    vcs = git
    [url "git@github.com:"]
	insteadOf = https://github.com/
  '';
  programs.git.userName = config.resources.fullName;
  programs.git.userEmail = config.resources.email;

  programs.zsh.shellAliases.ga="${pkgs.git}/bin/git add .";
  programs.zsh.shellAliases.gaf="${pkgs.git}/bin/git add";
  programs.zsh.shellAliases.gb="${pkgs.git}/bin/git branch";
  programs.zsh.shellAliases.gB="${pkgs.git}/bin/git rebase";
  programs.zsh.shellAliases.gBC="${pkgs.git}/bin/git add . && git rebase --continue";
  programs.zsh.shellAliases.gBc="${pkgs.git}/bin/git rebase --continue";
  programs.zsh.shellAliases.gbi="${pkgs.git}/bin/git branch -lvv";
  programs.zsh.shellAliases.gC="${pkgs.git}/bin/git commit -am";
  programs.zsh.shellAliases.gc="${pkgs.git}/bin/git commit";
  programs.zsh.shellAliases.gca="${pkgs.git}/bin/git commit --amend";
  programs.zsh.shellAliases.gcm="${pkgs.git}/bin/git commit -m";
  programs.zsh.shellAliases.gd="${pkgs.git}/bin/git diff --word-diff=color";
  programs.zsh.shellAliases.gdc="${pkgs.git}/bin/git diff --word-diff=color --cached";
  programs.zsh.shellAliases.gf="${pkgs.git}/bin/git fetch --all --prune";
  programs.zsh.shellAliases.gH1="${pkgs.git}/bin/git hist --shortstat --oneline";
  programs.zsh.shellAliases.gh1="${pkgs.git}/bin/git hist --oneline";
  programs.zsh.shellAliases.gH="${pkgs.git}/bin/git hist --shortstat";
  programs.zsh.shellAliases.gh="${pkgs.git}/bin/git hist";
  programs.zsh.shellAliases.gHH="${pkgs.git}/bin/git hist --shortstat --all";
  programs.zsh.shellAliases.ghh="${pkgs.git}/bin/git hist --all";
  programs.zsh.shellAliases.gL1="${pkgs.git}/bin/git log --word-diff=color --patch-with-stat --oneline";
  programs.zsh.shellAliases.gl1="${pkgs.git}/bin/git log --stat --date=short --oneline";
  programs.zsh.shellAliases.gl="${pkgs.git}/bin/git log --stat --date=short";
  programs.zsh.shellAliases.gL="${pkgs.git}/bin/git log --word-diff=color --patch-with-stat";
  programs.zsh.shellAliases.gLL="${pkgs.git}/bin/git log --word-diff=color --patch-with-stat --all";
  programs.zsh.shellAliases.gll="${pkgs.git}/bin/git log --stat --date=short --all";
  programs.zsh.shellAliases.gm="${pkgs.git}/bin/git cherry-pick";
  programs.zsh.shellAliases.gM="${pkgs.git}/bin/git merge";
  programs.zsh.shellAliases.gn="${pkgs.git}/bin/git checkout";
  programs.zsh.shellAliases.gnb="${pkgs.git}/bin/git checkout -b";
  programs.zsh.shellAliases.gno="${pkgs.git}/bin/git checkout --orphan";
  programs.zsh.shellAliases.gp="${pkgs.git}/bin/git pull";
  programs.zsh.shellAliases.gP="${pkgs.git}/bin/git push";
  programs.zsh.shellAliases.gpp="${pkgs.git}/bin/git pull --prune";
  programs.zsh.shellAliases.gPp="${pkgs.git}/bin/git push --prune";
  programs.zsh.shellAliases.gr="${pkgs.git}/bin/git remote";
  programs.zsh.shellAliases.gR="${pkgs.git}/bin/git reset";
  programs.zsh.shellAliases.gRh="${pkgs.git}/bin/git reset --hard";
  programs.zsh.shellAliases.grl="${pkgs.git}/bin/git reflog";
  programs.zsh.shellAliases.gS="${pkgs.git}/bin/git show --word-diff=color";
  programs.zsh.shellAliases.gs="${pkgs.git}/bin/git status";
  programs.zsh.shellAliases.gsl="${pkgs.git}/bin/git shortlog";
  programs.zsh.shellAliases.gT="${pkgs.git}/bin/git bigtree --summary --shortstat --dirstat";
  programs.zsh.shellAliases.gt="${pkgs.git}/bin/git tree";
  programs.zsh.shellAliases.gTT="${pkgs.git}/bin/git bigtree --summary --shortstat --dirstat --all";
  programs.zsh.shellAliases.gtt="${pkgs.git}/bin/git tree --all";
  programs.zsh.shellAliases.gy="${pkgs.git}/bin/git stash";
  programs.zsh.shellAliases.gyd="${pkgs.git}/bin/git stash drop";
  programs.zsh.shellAliases.gyp="${pkgs.git}/bin/git stash pop";
}
