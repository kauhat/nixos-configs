## Deploy Minecraft server

```sh
nixos-rebuild --target-host lxc-minecraft.home --use-remote-sudo switch --flake .#lxc-minecraft
```
