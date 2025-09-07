{ pkgs }:

{
  # Custom packages for ShinigamiNix
  # Add any custom packages or package derivations here
  
  # Example custom package
  # my-custom-tool = pkgs.writeShellScriptBin "my-custom-tool" ''
  #   echo "This is a custom tool for ShinigamiNix"
  # '';
  
  # Framework-specific scripts
  framework-optimize = pkgs.writeShellScriptBin "framework-optimize" ''
    #!/usr/bin/env bash
    # Framework 13 optimization script
    
    echo "Optimizing Framework 13 settings..."
    
    # Set CPU governor based on power state
    if [ -f /sys/class/power_supply/ADP0/online ]; then
      if [ "$(cat /sys/class/power_supply/ADP0/online)" = "1" ]; then
        echo "AC power detected - setting performance governor"
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      else
        echo "Battery power detected - setting powersave governor"
        echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      fi
    fi
    
    # Optimize GPU settings
    if [ -d /sys/class/drm/card0 ]; then
      echo "Optimizing GPU settings..."
      # Add GPU optimization commands here
    fi
    
    echo "Framework optimization complete!"
  '';
  
  # Gaming mode script
  gaming-mode = pkgs.writeShellScriptBin "gaming-mode" ''
    #!/usr/bin/env bash
    # Toggle gaming optimizations
    
    GAMING_MODE_FILE="/tmp/gaming_mode_active"
    
    if [ -f "$GAMING_MODE_FILE" ]; then
      echo "Disabling gaming mode..."
      rm "$GAMING_MODE_FILE"
      
      # Restore power saving settings
      echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      
      # Re-enable CPU mitigations
      echo 1 | sudo tee /sys/devices/system/cpu/vulnerabilities/*/mitigation 2>/dev/null || true
      
      echo "Gaming mode disabled - power saving restored"
    else
      echo "Enabling gaming mode..."
      touch "$GAMING_MODE_FILE"
      
      # Set performance settings
      echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      
      # Disable CPU mitigations for performance
      echo 0 | sudo tee /sys/devices/system/cpu/vulnerabilities/*/mitigation 2>/dev/null || true
      
      # Maximize GPU performance
      if [ -d /sys/class/drm/card0 ]; then
        echo "Setting GPU to maximum performance..."
        # Add GPU performance commands
      fi
      
      echo "Gaming mode enabled - maximum performance"
    fi
  '';
  
  # Development environment setup script
  dev-setup = pkgs.writeShellScriptBin "dev-setup" ''
    #!/usr/bin/env bash
    # Development environment setup script
    
    echo "Setting up development environment..."
    
    # Create common development directories
    mkdir -p ~/dev/{projects,scripts,tmp}
    mkdir -p ~/.config/{nvim,git}
    
    # Set up Git configuration if not already done
    if [ ! -f ~/.gitconfig ]; then
      echo "Setting up Git configuration..."
      read -p "Enter your Git username: " git_username
      read -p "Enter your Git email: " git_email
      
      git config --global user.name "$git_username"
      git config --global user.email "$git_email"
      git config --global init.defaultBranch main
      git config --global pull.rebase false
    fi
    
    # Set up SSH key if not exists
    if [ ! -f ~/.ssh/id_ed25519 ]; then
      echo "Generating SSH key..."
      ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
      echo "SSH public key:"
      cat ~/.ssh/id_ed25519.pub
      echo "Add this key to your Git hosting service"
    fi
    
    echo "Development environment setup complete!"
  '';
  
  # System info script
  shinigami-info = pkgs.writeShellScriptBin "shinigami-info" ''
    #!/usr/bin/env bash
    # ShinigamiNix system information
    
    echo "=== ShinigamiNix System Information ==="
    echo
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo
    echo "=== Hardware ==="
    echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Storage: $(df -h / | awk 'NR==2 {print $2 " total, " $4 " available"}')"
    echo
    echo "=== Graphics ==="
    if command -v glxinfo >/dev/null; then
      echo "GPU: $(glxinfo | grep "OpenGL renderer" | cut -d: -f2 | xargs)"
      echo "OpenGL: $(glxinfo | grep "OpenGL version" | cut -d: -f2 | xargs)"
    fi
    echo
    echo "=== NixOS ==="
    echo "Generation: $(nixos-version)"
    echo "Config location: /home/reaper/shinigaminix"
    echo
    echo "=== Hyprland ==="
    if pgrep -x "Hyprland" >/dev/null; then
      echo "Status: Running"
      echo "Version: $(Hyprland --version 2>/dev/null | head -1)"
    else
      echo "Status: Not running"
    fi
    echo
    echo "=== Gaming ==="
    if systemctl --user is-active --quiet gamemode; then
      echo "GameMode: Active"
    else
      echo "GameMode: Inactive"
    fi
    echo
  '';
  
  # Rebuild script with better feedback
  rebuild-system = pkgs.writeShellScriptBin "rebuild-system" ''
    #!/usr/bin/env bash
    # Enhanced NixOS rebuild script
    
    cd /home/reaper/shinigaminix || {
      echo "Error: Could not find shinigaminix directory"
      exit 1
    }
    
    echo "=== ShinigamiNix System Rebuild ==="
    echo "Configuration: $(pwd)"
    echo "Timestamp: $(date)"
    echo
    
    # Check for uncommitted changes
    if git status --porcelain | grep -q .; then
      echo "Warning: Uncommitted changes detected:"
      git status --short
      echo
      read -p "Continue anyway? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
      fi
    fi
    
    # Show current generation
    echo "Current generation: $(nixos-rebuild list-generations | tail -1)"
    echo
    
    # Perform the rebuild
    echo "Building new generation..."
    if sudo nixos-rebuild switch --flake . --show-trace; then
      echo
      echo "=== Rebuild Successful ==="
      echo "New generation: $(nixos-rebuild list-generations | tail -1)"
      
      # Update the wiki with the change
      if [ -f wiki.md ]; then
        echo "- $(date): System rebuild completed successfully" >> wiki.md
      fi
    else
      echo
      echo "=== Rebuild Failed ==="
      echo "Check the error messages above for details."
      exit 1
    fi
  '';
}
