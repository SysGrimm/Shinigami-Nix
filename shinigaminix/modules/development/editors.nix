{ config, lib, pkgs, ... }:

{
  # Enable and configure editors
  environment.systemPackages = with pkgs; [
    # Neovim with plugins
    neovim
    
    # VSCode/Codium
    vscode
    vscodium
    
    # Helix (modern modal editor)
    helix
    
    # Emacs
    emacs29
    
    # Vim
    vim
    
    # Nano for simple editing
    nano
    
    # GUI editors
    sublime4
    
    # Markdown editors
    obsidian
    typora
    
    # IDE support
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    jetbrains.rust-rover
    
    # Text processing
    pandoc
    texlive.combined.scheme-full
    
    # Documentation tools
    zeal # Offline documentation
  ];

  # Neovim as default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Configure programs
  programs = {
    # Neovim system-wide configuration
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      
      configure = {
        customRC = ''
          " Basic settings
          set number
          set relativenumber
          set tabstop=2
          set shiftwidth=2
          set expandtab
          set smartindent
          set wrap
          set smartcase
          set noswapfile
          set nobackup
          set undodir=~/.vim/undodir
          set undofile
          set incsearch
          set termguicolors
          set scrolloff=8
          set signcolumn=yes
          set colorcolumn=80,120
          
          " Performance
          set updatetime=50
          
          " Leader key
          let mapleader = " "
          
          " Basic keymaps
          nnoremap <leader>pv :Ex<CR>
          nnoremap <C-p> :find 
          nnoremap <leader>u :UndotreeShow<CR>
        '';
        
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # Essential plugins
            telescope-nvim
            nvim-treesitter.withAllGrammars
            nvim-lspconfig
            nvim-cmp
            cmp-nvim-lsp
            cmp-buffer
            cmp-path
            luasnip
            
            # File explorer
            nvim-tree-lua
            
            # Git integration
            fugitive
            gitsigns-nvim
            
            # Status line
            lualine-nvim
            
            # Color scheme
            tokyonight-nvim
            
            # Utilities
            undotree
            vim-commentary
            vim-surround
            
            # Language specific
            rust-vim
            vim-nix
            
            # Development
            nvim-dap
            nvim-dap-ui
          ];
        };
      };
    };
  };

  # LSP servers and development tools
  environment.systemPackages = with pkgs; [
    # Language servers
    nil              # Nix LSP
    rust-analyzer    # Rust LSP
    gopls           # Go LSP
    nodePackages.typescript-language-server  # TypeScript LSP
    nodePackages.pyright  # Python LSP
    lua-language-server    # Lua LSP
    marksman        # Markdown LSP
    
    # Formatters
    nixpkgs-fmt     # Nix formatter
    rustfmt         # Rust formatter
    gofmt           # Go formatter
    nodePackages.prettier  # JS/TS/JSON formatter
    black           # Python formatter
    
    # Linters
    statix          # Nix linter
    clippy          # Rust linter
    golangci-lint   # Go linter
    nodePackages.eslint  # JS/TS linter
    ruff            # Python linter
    
    # Debuggers
    gdb
    lldb
    
    # Git tools
    git-crypt
    git-lfs
    gitui
    lazygit
    delta           # Better git diff
    
    # Terminal multiplexer
    tmux
    zellij
    
    # File managers
    ranger
    nnn
    
    # Search tools
    ripgrep
    fd
    fzf
    
    # System monitoring
    htop
    btop
    iotop
    iftop
    
    # Network tools
    nmap
    wireshark
    
    # Archive tools
    zip
    unzip
    p7zip
    unrar
    
    # Image tools
    imagemagick
    
    # PDF tools
    poppler_utils
    
    # JSON tools
    jq
    yq
  ];
}
