{ pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    backupDir = null;
    config = {
      WEB_VAULT_ENABLED = true;
      ROCKET_ADDRESS = "10.245.0.2";
      ROCKET_PORT = 8000;
      ROCKET_TLS = ''{certs="/var/lib/vaultwarden-tls/polevault+4.pem",key="/var/lib/vaultwarden-tls/polevault+4-key.pem"}'';
      DOMAIN = "https://10.245.0.2:8000";
      SENDS_ALLOWED = false;
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = false;
      PASSWORD_HINTS_ALLOWED = false;
      EXTENDED_LOGGING = true;
      USE_SYSLOG = true;
    };
  };

  fileSystems."/var/lib/bitwarden_rs" = {
    device = "vaultwarden-data";
    fsType = "virtiofs";
  };

  systemd.services = {
    fix-vaultwarden-perms = {
      after = [ "var-lib-bitwarden_rs.mount" ];
      path = [
        pkgs.coreutils
        pkgs.findutils
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        find /var/lib/bitwarden_rs -type d -exec chmod 700 {} +
        find /var/lib/bitwarden_rs -type f -exec chmod 600 {} +
        chown -R vaultwarden:vaultwarden /var/lib/bitwarden_rs
        mkdir -p /var/lib/vaultwarden-tls
        chown -R vaultwarden:vaultwarden /var/lib/vaultwarden-tls
      '';
    };
    setup-vaultwarden-certs = {
      after = [ "fix-vaultwarden-perms.service" ];
      path = [
        pkgs.coreutils
        pkgs.mkcert
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        export HOME=/root

        mkcert polevault 10.245.0.2 localhost 127.0.0.1 ::1

        mkdir -p /var/lib/vaultwarden-tls
        mv polevault+4.pem /var/lib/vaultwarden-tls
        mv polevault+4-key.pem /var/lib/vaultwarden-tls

        chmod 755 /var/lib/vaultwarden-tls
        chmod 644 /var/lib/vaultwarden-tls/polevault+4.pem
        chmod 644 /var/lib/vaultwarden-tls/polevault+4-key.pem
        chown vaultwarden:vaultwarden -R /var/lib/vaultwarden-tls
      '';
    };
    vaultwarden = {
      after = [
        "fix-vaultwarden-perms.service"
        "setup-vaultwarden-certs.service"
      ];
      wants = [
        "fix-vaultwarden-perms.service"
        "setup-vaultwarden-certs.service"
      ];
    };
  };

  users.users.vaultwarden = {
    uid = 50001;
    group = "vaultwarden";
  };
  users.groups.vaultwarden = {
    gid = 50001;
  };
}
