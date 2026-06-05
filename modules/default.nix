{
  imports = [
    ./network.nix
    ./pattern.nix
    ./users.nix
    ./vaultwarden.nix
  ];

  boot.kernelParams = [ "console=ttyS0" ];
  system.stateVersion = "24.05";
}
