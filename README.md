# yanwen-homeserver


## Currently my list of services

* Immich [link](https://immich.app/docs/install/portainer)
* Jellyfin [link](0)
* 


## Making VM templates

### Debian

## Special instructionrs

### Podman-portainer

good article [link](https://blog.while-true-do.io/podman-portainer/).

#### Portainer (rootful)

this time I am going to use `lts` version of the portainer (should be `2.21.0` LTS)

```bash
# Start portainer (rootful)
sudo podman run \
  --detach \
  -p 9443:9443 \
  --privileged \
  --name portainer \
  --volume /run/podman/podman.sock:/var/run/docker.sock:Z \
  --volume portainer_data:/data:Z \
  docker.io/portainer/portainer-ce:lts
```

#### Portainer (rootless)

Rootless Podman uses rootless API ports. Therefor, we need to start this service, first.

```bash
systemctl --user enable --now podman.socket
```

There is an issue, though. Normally, systemd does not care about user services until the user is logged in. To enable "lingering", we need to run one more command.

```bash
# enable start of system services, even if not logged in
sudo loginctl enable-linger $USER
```

Starting Portainer works similar to the rootful deployment, though. There are some differences, you need to take care of.

```bash
# Start portainer rootless
podman run \
  --detach \
  -p 9444:9443 \
  --name portainer \
  --security-opt label=disable \
  --volume /run/user/$(id -u)/podman/podman.sock:/var/run/docker.sock:Z \
  --volume portainer_data:/data:Z \
  docker.io/portainer/portainer-ce
```
