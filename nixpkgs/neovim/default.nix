pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    vim-table-mode
  ];
  configure.packages.plugins.start = with pkgs.vimPlugins; [
    auto-pairs
    base16-vim
    direnv-vim
    editorconfig-vim
    fugitive
    fzf-vim
    fzfWrapper
    gitv
    incsearch-vim
    neoinclude
    neosnippet
    neosnippet-snippets
    nerdcommenter
    repeat
    surround
    tabular
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-autoformat
    vim-bufferline
    vim-devicons
    vim-dirvish
    vim-ghost
    vim-plugin-AnsiEsc
    vim-polyglot
    vim-signify
    vim-unimpaired
    vim-visual-multi
    vim-visualstar
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    coc-nvim
    vim-go
  ];

  extraPython3Packages = (ps: with ps; [ 
    python-slugify
    simple-websocket-server
  ]);

  viAlias = true;
  vimAlias = true;
  withNodeJs = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
}
