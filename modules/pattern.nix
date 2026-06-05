{ inputs, ... }:

{
  imports = [ inputs.pattern.nixosModules.pattern ];

  pattern = {
    image = {
      id = "polevault";
      version = "vm";
      updates.enable = false;
    };
    partitions = {
      disk = "/dev/sda";
      sizes = {
        esp = "200M";
        verity = "200M";
        usr = "1G";
      };
      persist = {
        etc = false;
        home = false;
        srv = false;
        var = false;
      };
    };
    userspace = {
      homed = false;
      desktop = false;
      distrobox = false;
      sandboxing = false;
    };
    debug = false;
  };
}
