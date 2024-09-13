#!/usr/bin/env fish

# list of image urls (latest versions)
set -g image_urls "debian=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2" \
    "ubuntu=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img" \
    "fedora=https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"

# [helper] the download file name is the last part of the url after the last '/'
function get_download_name
    set -l url $argv[1]
    set -l file_name (string split -m 1 -r / $url)
    echo $file_name[-1]
end

# this function takes in the image name (key) and downloads the image
function get_image
    set -l os_name $argv[1]
    set -l image_url (echo $image_urls | grep -oP "$os_name=\K[^ ]+")

    set -l file_name (get_download_name $image_url)

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

# main function
# if is interactive shell, prompt user for image name
if test (count $argv) -lt 1
    echo "Usage: get_image <image_name>"
else
    get_image $argv[1]
end
