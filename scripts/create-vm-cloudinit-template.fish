#!/usr/bin/env fish

set -g STORAGE local-zfs
set -g USER doremy
set -g VENDOR_LOCATIONS /var/lib/vz/snippets

# Function to create the VM
function create_vm
    # first argument is the vmid
    set vmid $argv[1]

    # second argument is the desired name of the VM
    set vm_name $argv[2]


    # check if vmid already exists
    if qm status $vmid &>/dev/null
        echo "VM $vmid already exists"
        return 1
    end

    echo "Creating VM $vmid with name $vm_name"

    #
    qm create $vmid --name "$vm_name" --ostype l26 \
        --memory 2048 --balloon 512 \
        --agent 1 \
        --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
        --cpu host --cores 2 --numa 1 \
        --vga serial0 --serial0 socket \
        --net0 virtio,bridge=vmbr0
end

# Function to import the disk image
function import_disk
    # first argument is the vmid
    set vmid $argv[1]

    # second argument is the filename of the disk image
    set image_name $argv[2]

    # Import the disk image
    qm importdisk $vmid $image_name $STORAGE

    # Set the imported disk as the main disk
    qm set $vmid --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$vmid-disk-1,discard=on
    qm set $vmid --boot order=virtio0
end

# Function to create the cloud-init configuration
function create_cloudinit_config
    set vmid $argv[1]
    set os_name $argv[2]

    cp ../cloud-init/vendor/$os_name.yaml $VENDOR_LOCATIONS/$os_name.yaml
    echo "Copied vendor file to $VENDOR_LOCATIONS/$os_name.yaml"

    # Set Cloud-Init custom vendor file, user, and SSH keys
    qm set $vmid --ide2 $STORAGE:cloudinit
    qm set $vmid --cicustom "vendor=local:snippets/$os_name.yaml"
    qm set $vmid --ciuser $USER
    qm set $vmid --sshkeys ~/.ssh/authorized_keys
    qm set $vmid --ipconfig0 ip=dhcp
end



create_vm 666 test-dabian
import_disk 666 debian-12-generic-amd64.qcow2
create_cloudinit_config 666 debian
