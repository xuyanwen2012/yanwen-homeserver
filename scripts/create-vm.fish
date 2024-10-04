#!/usr/bin/env fish

set -g STORAGE local-zfs
set -g VENDOR_LOCATIONS /var/lib/vz/snippets
set -g USER doremy

# list of image urls (latest versions)
set -g IMAGE_URLS "debian=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2" \
    "ubuntu=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img" \
    "fedora=https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"

# [helper] get the os name from the filename of cloud-init yaml file (e.g., "../cloud-init/vendor/debian-docker.yaml")
# the name is the part after the last '/' and before the first (or '.')
function get_os_name
    set file_name $argv[1]
    set os_name (string split -m 1 -r / $file_name)
    set os_name (string split -m 1 -r . $os_name[-1])
    set os_name (string split -m 1 -r - $os_name)
    echo $os_name[1]
end

# this function takes in the image name (key) and downloads the image
function get_image
    # first argument is the image name (e.g., debian)
    set os_name $argv[1]
    set image_url (echo $IMAGE_URLS | grep -oP "$os_name=\K[^ ]+")
    set file_name $os_name.qcow2

    # check if image link exists
    if test -z $file_name
        echo "Image not found"
        return 1
    end

    # check if file already exists, prompt user to overwrite
    if test -f $file_name
        echo "File $file_name already exists. Overwrite? [y/n]"
        read -l overwrite
        if test $overwrite = n
            return 0
        end
    end

    echo "Downloading $file_name from $image_url"

    # download the image and resize it to 32G
    wget --show-progress -O $file_name $image_url

    qemu-img resize $file_name 32G
end


# Function to create the VM
function create_vm
    # first argument is the vmid
    set vmid $argv[1]

    # second argument is the desired name of the VM
    set vm_name $argv[2]

    echo "Creating VM $vmid with name $vm_name" with default settings

    qm create $vget_imagehost --cores 2 --numa 1 \
        --vga serial0 --serial0 socket \
        --net0 virtio,bridge=vmbr0
end

# Function to import the disk image
function import_disk
    # first argument is the vmid
    set vmid $argv[1]

    # second argument is the filename of the disk image
    set file_name $argv[2]

    echo "Importing disk $file_name"

    qm importdisk $vmid $file_name $STORAGE

    # Set the imported disk as the main disk
    qm set $vmid --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$vmid-disk-1,discard=on
    qm set $vmid --boot order=virtio0
end

# Function to create the cloud-init configuration
function create_cloudinit_config
    # first argument is the vmid
    set vmid $argv[1]

    # second argument is the path to the cloud-init yaml file
    # set os_name $argv[2]
    set cloud_init_file $argv[2]

    # cp ../cloud-init/vendor/$os_name.yaml $VENDOR_LOCATIONS/$os_name.yaml
    # echo "Copied vendor file to $VENDOR_LOCATIONS/$os_name.yaml"

    set os_name (get_os_name $cloud_init_file)

    cp $cloud_init_file $VENDOR_LOCATIONS/$os_name.yaml
    echo "Copied vendor file to $VENDOR_LOCATIONS/$os_name.yaml"

    # Set Cloud-Init custom vendor file, user, and SSH keys
    qm set $vmid --ide2 $STORAGE:cloudinit
    qm set $vmid --cicustom "vendor=local:snippets/$os_name.yaml"
    qm set $vmid --ciuser $USER
    qm set $vmid --sshkeys ~/.ssh/authorized_keys
    qm set $vmid --ipconfig0 ip=dhcp
end


# [main] 
# takes a vmid and a vm_name, and a path to cloud-init yaml file 

if test (count $argv) -lt 3
    echo "Usage: create_vm <vmid> <vm_name> <cloud_init_file>"
    return 1
end

set vmid $argv[1]
set vm_name $argv[2]
set cloud_init_file $argv[3]

# check if vmid already exists
if qm status $vmid &>/dev/null
    echo "VM $vmid already exists"
    return 1
end

if not test -f $cloud_init_file
    echo "Cloud-init file $cloud_init_file not found"
    return 1
end


set os_name (get_os_name $cloud_init_file)
set file_name $os_name.qcow2

get_image $os_name
create_vm $vmid $vm_name
import_disk $vmid $file_name
create_cloudinit_config $vmid $cloud_init_file
