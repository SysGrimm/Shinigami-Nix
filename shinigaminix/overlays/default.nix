{ config, lib, pkgs, ... }:

{
  # Custom overlays for ShinigamiNix
  nixpkgs.overlays = [
    # Gaming optimizations overlay
    (final: prev: {
      # Custom Steam with additional Proton versions
      steam-custom = prev.steam.override {
        extraPkgs = pkgs: with pkgs; [
          # Additional dependencies for better game compatibility
          gamemode
          mangohud
          libgdiplus
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
        ];
      };
      
      # Custom Hyprland with additional patches (if needed)
      hyprland-custom = prev.hyprland.overrideAttrs (old: {
        # Add any custom patches or configurations here if needed
        postPatch = (old.postPatch or "") + ''
          # Custom patches can go here
        '';
      });
      
      # Enhanced Neovim with more plugins
      neovim-enhanced = prev.neovim.override {
        configure = {
          packages.myVimPackage = with prev.vimPlugins; {
            start = [
              # Core plugins
              telescope-nvim
              nvim-treesitter.withAllGrammars
              nvim-lspconfig
              nvim-cmp
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              luasnip
              
              # File management
              nvim-tree-lua
              oil-nvim
              
              # Git integration
              fugitive
              gitsigns-nvim
              diffview-nvim
              
              # UI enhancements
              lualine-nvim
              bufferline-nvim
              indent-blankline-nvim
              nvim-web-devicons
              
              # Color schemes
              tokyonight-nvim
              catppuccin-nvim
              onedark-nvim
              
              # Utilities
              undotree
              vim-commentary
              vim-surround
              auto-pairs
              vim-sleuth
              
              # Language specific
              rust-vim
              vim-nix
              vim-go
              typescript-vim
              
              # Development tools
              nvim-dap
              nvim-dap-ui
              trouble-nvim
              
              # Terminal integration
              toggleterm-nvim
              
              # Session management
              auto-session
              
              # Productivity
              which-key-nvim
              nvim-autopairs
              
              # Markdown
              markdown-preview-nvim
              
              # Database
              vim-dadbod
              vim-dadbod-ui
              
              # Testing
              neotest
              
              # AI assistance (if available)
              # copilot-vim  # Uncomment if you have GitHub Copilot
            ];
          };
        };
      };
    })
    
    # Development tools overlay
    (final: prev: {
      # Enhanced development environment
      dev-shell = prev.mkShell {
        buildInputs = with prev; [
          # Core development tools
          git
          gh
          lazygit
          
          # Language servers
          nil              # Nix
          rust-analyzer    # Rust
          gopls           # Go
          nodePackages.typescript-language-server
          nodePackages.pyright
          
          # Formatters
          nixpkgs-fmt
          rustfmt
          gofmt
          nodePackages.prettier
          black
          
          # Linters
          statix
          clippy
          golangci-lint
          nodePackages.eslint
          
          # Build tools
          cmake
          ninja
          meson
          
          # Containers
          docker-compose
          podman
          
          # Cloud tools
          kubectl
          helm
          terraform
          
          # Monitoring
          htop
          btop
          
          # Networking
          curl
          httpie
          
          # File processing
          jq
          yq
          
          # Search tools
          ripgrep
          fd
          fzf
        ];
        
        shellHook = ''
          echo "Development environment loaded!"
          echo "Available tools: git, docker, kubectl, terraform, and more..."
        '';
      };
    })
    
    # Theming overlay
    (final: prev: {
      # Custom GTK theme based on Tokyo Night
      tokyo-night-gtk = prev.stdenv.mkDerivation rec {
        pname = "tokyo-night-gtk";
        version = "1.0.0";
        
        src = prev.fetchFromGitHub {
          owner = "Fausto-Korpsvart";
          repo = "Tokyo-Night-GTK-Theme";
          rev = "master";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
        };
        
        installPhase = ''
          mkdir -p $out/share/themes
          cp -r themes/* $out/share/themes/
        '';
        
        meta = {
          description = "Tokyo Night theme for GTK";
          license = lib.licenses.gpl3;
          platforms = lib.platforms.linux;
        };
      };
    })
    
    # Gaming-specific overlay
    (final: prev: {
      # Enhanced gaming suite
      gaming-suite = prev.buildEnv {
        name = "gaming-suite";
        paths = with prev; [
          # Game launchers
          steam
          lutris
          heroic
          bottles
          
          # Emulation
          retroarch
          dolphin-emu
          pcsx2
          rpcs3
          
          # Gaming tools
          gamemode
          mangohud
          goverlay
          
          # Performance monitoring
          nvtop
          radeontop
          
          # Audio/Video
          obs-studio
          discord
          
          # Controllers
          antimicrox
          
          # Wine
          wineWowPackages.waylandFull
          winetricks
        ];
      };
      
      # Custom MangoHud configuration
      mangohud-custom = prev.mangohud.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          # Add custom MangoHud configuration
          mkdir -p $out/share/mangohud
          cat > $out/share/mangohud/MangoHud.conf << EOF
          cpu_temp
          gpu_temp
          cpu_power
          gpu_power
          cpu_mhz
          gpu_core_clock
          ram
          vram
          swap
          fps
          frametime=0
          frame_timing=1
          position=top-left
          text_color=FFFFFF
          gpu_color=2e9762
          cpu_color=2e97cb
          vram_color=ad64c1
          ram_color=c26693
          engine_color=eb5b5b
          io_color=a491d3
          background_alpha=0.4
          font_size=24
          background_color=020202
          round_corners=10
          toggle_hud=Shift_R+F12
          reload_cfg=Shift_L+F4
          upload_log=Shift_L+F3
          EOF
        '';
      });
    })
    
    # Framework-specific overlay
    (final: prev: {
      # Framework 13 specific tools
      framework-tools = prev.buildEnv {
        name = "framework-tools";
        paths = with prev; [
          # Power management
          powertop
          tlp
          
          # Hardware monitoring
          lm_sensors
          dmidecode
          
          # Firmware
          fwupd
          
          # Expansion card tools
          # (Framework-specific tools would go here)
        ];
      };
    })
  ];
}
