with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = let
    nixosVersion = "19.03";

    keybaseRepos = [ "vendor/pass" "vendor/pass-ttn-shared" "vendor/pass-otp" "vendor/secrets" ];

    doIfEmpty = path: action: cmd: ''
      if [ -d "${path}" ] && [ "$(${coreutils}/bin/ls -A "${path}")" ]; then
        echo "${path} already exists and is non-empty, skip ${action}"
      else
        ${cmd}
      fi
    '';

    cloneIfEmpty = path: url: branch: doIfEmpty path "cloning" ''
      ${git}/bin/git clone --branch "${branch}" "${url}" "${path}"
    '';

    addWorkTreeIfEmpty  = path: commitish: doIfEmpty path "adding worktree" ''
      ${git}/bin/git worktree add "${path}" "${commitish}"
    '';

    upsertRemote = name: url: ''
      if [ $(${git}/bin/git remote | ${ripgrep}/bin/rg "${name}") ]; then
        echo "remote ${name} already exists, setting URL to ${url}"
        ${git}/bin/git remote set-url "${name}" "${url}"
      else
        ${git}/bin/git remote add "${name}" "${url}"
      fi
    '';

    cloneGitHubSource = repo: branch: preFetch: postFetch: ''
      ${cloneIfEmpty "../${repo}" "https://github.com/rvolosatovs/${repo}.git" branch}

      pushd "../${repo}"

      ${git}/bin/git remote set-url origin --push git@github.com:rvolosatovs/${repo}.git

      ${preFetch}

      ${git}/bin/git fetch --all

      ${postFetch}

      popd
    '';

    cloneGitHubFork = owner: repo: branch: preFetch: postFetch: ''
      ${cloneIfEmpty "../../${owner}/${repo}" "https://github.com/rvolosatovs/${repo}.git" branch}

      pushd "../../${owner}/${repo}"

      ${git}/bin/git remote set-url origin --push git@github.com:rvolosatovs/${repo}.git
      ${upsertRemote "upstream" "https://github.com/${owner}/${repo}.git"}

      ${preFetch}

      ${git}/bin/git fetch --all

      ${postFetch}

      popd
    '';

    vendorGitHubFork = owner: repo: forkBranch: upstreamBranch: ''
      ${cloneGitHubFork owner repo forkBranch "" ''
        ${git}/bin/git checkout "origin/${forkBranch}"
        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/${repo}" forkBranch}
        pushd "../../rvolosatovs/infrastructure/vendor/${repo}"
        ${git}/bin/git branch --set-upstream-to="upstream/${upstreamBranch}"
        popd
      ''}
    '';

    vendorGitHubForkMaster = owner: repo: vendorGitHubFork owner repo "master" "master";

    vendorGitHubSource = repo: branch: ''
      ${cloneGitHubSource repo branch "" ''
        ${git}/bin/git checkout "origin/${branch}"
        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/${repo}" branch}
        pushd "../../rvolosatovs/infrastructure/vendor/${repo}"
        ${git}/bin/git branch --set-upstream-to="origin/${branch}"
        popd
      ''}
    '';

    vendorGitHubSourceMaster = repo: vendorGitHubSource repo "master";
    vendorGitHubSourceStable = repo: vendorGitHubSource repo "stable";

    vendorKeybasePrivateSource = repo: branch: ''
      ${cloneIfEmpty "vendor/${repo}" "keybase://private/rvolosatovs/${repo}" branch}
    '';

    vendorKeybasePrivateSourceMaster = repo: vendorKeybasePrivateSource repo "master";

    bootstrap-master = writeShellScriptBin "bootstrap-master" ''
      set -e

      ${cloneGitHubFork "NixOS" "nixpkgs" "master" ''
        ${upsertRemote "channels" "https://github.com/NixOS/nixpkgs-channels.git"}
      '' ''
        ${git}/bin/git checkout master

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos" "nixos"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos"
        ${git}/bin/git branch --set-upstream-to=channels/nixos-${nixosVersion}
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos-unstable" "nixos-unstable"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos-unstable"
        ${git}/bin/git branch --set-upstream-to=channels/nixos-unstable
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin" "darwin"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin"
        ${git}/bin/git branch --set-upstream-to=channels/nixpkgs-${nixosVersion}-darwin
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin-unstable" "darwin-unstable"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin-unstable"
        ${git}/bin/git branch --set-upstream-to=channels/nixpkgs-unstable
        popd
      ''}

      ${vendorGitHubFork "rycee" "home-manager" "stable" "release-${nixosVersion}"}

      ${vendorGitHubForkMaster "chriskempson" "base16-shell"}
      ${vendorGitHubForkMaster "Homebrew" "brew"}
      ${vendorGitHubForkMaster "jitsi" "docker-jitsi-meet"}
      ${vendorGitHubForkMaster "keyboardio" "Model01-Firmware"}
      ${vendorGitHubForkMaster "LnL7" "nix-darwin"}
      ${vendorGitHubForkMaster "nix-community" "nur"}
      ${vendorGitHubForkMaster "NixOS" "nixos-hardware"}
      ${vendorGitHubForkMaster "qmk" "qmk_firmware"}
      ${vendorGitHubForkMaster "StevenBlack" "hosts"}

      ${vendorGitHubSourceMaster "copier"}
      ${vendorGitHubSourceMaster "dumpster"}
      ${vendorGitHubSourceMaster "gorandr"}

      ${vendorKeybasePrivateSourceMaster "pass"}
      ${vendorKeybasePrivateSourceMaster "pass-otp"}
      ${vendorKeybasePrivateSourceMaster "pass-ttn-shared"}
      ${vendorKeybasePrivateSourceMaster "secrets"}
    '';

    writeAllReposScriptBin = name: action: writeShellScriptBin name (''
      set -x
      ${action}
      ${git}/bin/git submodule foreach "${action} || :"
    '' + lib.concatMapStringsSep "\n" (x: "(cd ${x} && ${action})") keybaseRepos);

    fetchAll = writeAllReposScriptBin "fetch-all" "${git}/bin/git fetch --prune --all";
    pullAll = writeAllReposScriptBin "pull-all" "${git}/bin/git pull";
    pushAll = writeAllReposScriptBin "push-all" "${git}/bin/git push -f --prune origin :";

    pullAndDeploy = writeShellScriptBin "pull-and-deploy" ''
      set -ex
      ${pullAll}/bin/pull-all
      ${nixops}/bin/nixops deploy "''${@}"
    '';

    nixDarwin = (import <darwin> {}).system;

    bootstrap-mac = writeShellScriptBin "bootstrap-mac" ''
      set -e

      ${cloneGitHubFork "NixOS" "nixpkgs" "master" ''
        ${upsertRemote "channels" "https://github.com/NixOS/nixpkgs-channels.git"}
      '' ''
        ${git}/bin/git checkout master

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin" "darwin"}
        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin-unstable" "darwin-unstable"}
      ''}

      ${vendorGitHubSourceMaster "base16-shell"}
      ${vendorGitHubSourceMaster "copier"}
      ${vendorGitHubSourceMaster "dumpster"}
      ${vendorGitHubSourceMaster "gorandr"}
      ${vendorGitHubSourceMaster "brew"}
      ${vendorGitHubSourceMaster "hosts"}
      ${vendorGitHubSourceMaster "nix-darwin"}
      ${vendorGitHubSourceMaster "nur"}

      ${vendorGitHubSourceStable "home-manager"}
      ${vendorGitHubSourceStable "Model01-Firmware"}
      ${vendorGitHubSourceStable "qmk_firmware"}
    '';

    upgrade-mac = writeShellScriptBin "upgrade-mac" ''
      set -ex
      ${git}/bin/git pull
      ${git}/bin/git submodule update
      $(${nix}/bin/nix-build '<darwin>' -A system --no-out-link)/sw/bin/darwin-rebuild switch "''${@}"
      ./vendor/brew/bin/brew bundle install --global
    '';
  in [
    fetchAll
    pullAll
    pullAndDeploy
    pushAll
  ] ++ [
    git
    neovim
    nixops
  ] ++ lib.optionals stdenv.isLinux [
    bootstrap-master
    keybase
  ] ++ lib.optionals stdenv.isDarwin [
    bootstrap-mac
    upgrade-mac
  ];
}
