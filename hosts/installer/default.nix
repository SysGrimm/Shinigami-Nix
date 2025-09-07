{ config, pkgs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland.nix
  ];

  # Make this ISO hardware-agnostic
  isoImage = {
    isoName = "nixos-hyprland-installer.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  environment.systemPackages = with pkgs; [
    steam
    vscode
    brave
    chiaki-ng
    discord
    prismlauncher
    tailscale
  ];

  # Enable Tailscale service (user will need to run tailscale up)
  services.tailscale.enable = true;

  # Steam needs 32-bit libraries
  hardware.opengl.driSupport32Bit = true;

  # General optimizations for compatibility
  services.xserver.videoDrivers = [ "modesetting" "intel" "nvidia" "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.supportedFilesystems = [ "btrfs" "ext4" "ntfs" "vfat" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Set a default user for live session
  users.users.nixos = {
    isNormalUser = true;
    password = "nixos";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Allow sudo without password for live user
  security.sudo.wheelNeedsPassword = false;

  # Set a default locale and timezone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";
}
