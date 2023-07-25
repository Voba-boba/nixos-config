{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    cryptlvm = {
      device="/dev/disk/by-uuid/50d9fc9e-a851-4f45-9471-8aaaaf1ab4fb";
      preLVM = true;
     };
    cryptmedia = {
      device = "/dev/disk/by-uuid/8d6eb9fb-bcbe-480f-83bd-970da915096c";
      preLVM = true;
    };
  };
  boot.initrd.luks.reusePassphrases = true;
  #services.logind.lidSwitch = "hybrid-sleep";

  nix = {
    settings.allowed-users = [ "@wheel" ];
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  # nixpkgs.config.allowUnfree = true;

  networking.hostName = "cone"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  services.strongswan.enable = true;
  networking.networkmanager.enableStrongSwan = true;
  environment.etc."ssl/certs/isrgrootx1.pem".source = builtins.fetchurl {
    url = "https://letsencrypt.org/certs/isrgrootx1.pem";
    sha256 = "1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
  };

  # Set your time zone.
  time.timeZone = "Asia/Tomsk";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "ru_RU.UTF-8";
    supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  };

  console = {
    font = "LatGrkCyr-8x16";
    keyMap = "us";
    #useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable GNOME.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      tap-to-click=true
      speed=0.4
      '';
    extraGSettingsOverridePackages = [ pkgs.gsettings-desktop-schemas ];
  };
    
  services.xserver.displayManager.gdm.enable = true;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome.cheese epiphany ];

  # Touchpad
  services.xserver.libinput.enable = true;

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Configure keymap in X11
  services.xserver.layout = "us,ru";
  #services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    description = "Егор";
  };

  # Installed packages
  environment.systemPackages = with pkgs; [
    wget
    celluloid
    # gnomeExtensions.rounded-window-corners
  ];
  environment.defaultPackages = with pkgs; [ perl rsync strace ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # Doesn't work with flakes.
  #system.copySystemConfiguration = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  system.autoUpgrade.flake = "/home/sei/system-config/";
  system.autoUpgrade.flags = [ "--update-inputs" "nixpkgs" "--commit-lock-file" ];

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  system.stateVersion = "23.05";

}
