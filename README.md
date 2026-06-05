# polevault

[pattern](https://github.com/sotormd/pattern) to access backup vaultwarden
vaults when away from main server

for my personal use.

# usage

0. clone this repo

   ```bash
   git clone https://github.com/sotormd/polevault
   cd polevault
   ```

1. build image

   ```bash
   nix build .#nixosConfigurations.polevault.config.pattern.release --option allow-import-from-derivation true
   ```

2. setup image

   this step may require elevated privileges

   ```bash
   export IMAGE="/var/lib/libvirt/images/polevault_vm.raw"
   cp result/polevault_vm.raw "$IMAGE"
   chmod +w "$IMAGE"
   qemu-img resize -f raw "$IMAGE" "+1G"
   ```

3. setup network and vm

   this step may require elevated privileges

   ```bash
   virsh net-define network.xml
   virsh define vm.xml
   ```

4. move your backup vault to `/persist/polevault/vault`

   this step may require elevated privileges

   ```bash
   mkdir -p /persist/polevault/vault
   cp -r /path/to/backup/bitwarden_rs /persist/polevault/vault
   ```

5. start network `polevault` and vm with domain `polevault`

6. access the web vault using the provided browser

   ```bash
   nix run .#browser
   ```

   this browser is a bubblewrapped policied kiosk firefox that can only access
   the polevault vaultwarden webvault.

   note that the browser will complain about the HTTPS certificates not being
   trusted, this can be ignored. the polevault vm uses `mkcert` to generate new
   privately-signed certificates every boot.

   copy-paste works within the browser and downloads go to
   `$XDG_RUNTIME_DIR/polevault-browser-downloads/`.
