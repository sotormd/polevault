{
  networking = {
    hostName = "polevault";
    useDHCP = false;
    firewall.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-primary" = {
      matchConfig.MACAddress = "52:54:00:23:80:48";
      address = [ "10.245.0.2/24" ];
      routes = [ { Gateway = "10.245.0.1"; } ];
      networkConfig.DHCP = "no";
    };
  };
}
