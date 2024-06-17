# Yanwen's post-install scripts for VMs

Pretty much 90% of my VMs will use docker.

## VM basic setup

After create VM:

* Set user to root
* Give root user a password
* Regenerate Image

For the following scripts, mostly just install `docker`, `fish` shell, `helix` editor.

### Debian 12.5 VM

run 
```
curl -sSL https://raw.githubusercontent.com/xuyanwen2012/yanwen-homeserver/main/post-install-scripts/vm-debian12-docker.sh | sudo bash
```

### Ubuntu 24.04 VM

run
```
curl -sSL https://raw.githubusercontent.com/xuyanwen2012/yanwen-homeserver/main/post-install-scripts/vm-ubuntu-docker.sh | sudo bash
```
maybe you want get SSH going, if you used pubkey

```
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
systemctl restart sshd
```

## For Docker Manager

we can choise from 

### Lazy Docker (preffered)

No need to create accounts for web UI, it just work. 

Just put all compose_file in the user's directory, like in `~/`

Use docker for Lazy docker, set alias in *fish* shell config

```
echo "alias lzd='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v ~/.config/lazydocker:/.config/jesseduffield/lazydocker lazyteam/lazydocker'" >> ~/.config/fish/config.fish
```

### Dockge (for small test projects)

```
mkdir -p /opt/{dockge,stacks}
wget -q -O /opt/dockge/compose.yaml https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml
cd /opt/dockge
docker compose up -d
```

### Portainer (for production)

```
docker volume create portainer_data
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```


## Development VMs 

Using The purpose of these VM is for setting development enviroments for various projects `C++/CUDA/SYCL` etc, which uses the latest features.


