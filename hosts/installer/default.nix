{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
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

  # Hardware compatibility for various systems
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Boot configuration for live ISO
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" "ext4" "ntfs" "vfat" "zfs" ];
  
  # Network and hardware detection
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
