#!/usr/bin/env ash

#
# NVMe Cache Patch by AuxXxilium
#

getnvmecache () {
    nvme0=$(udevadm info --query path --name nvme0n1 | awk -F "\/" '{print $4 ":" $5 }' | awk -F ":" '{print $2 ":" $3}' | sed 's/,*$//')
    nvme1=$(udevadm info --query path --name nvme1n1 | awk -F "\/" '{print $4 ":" $5 }' | awk -F ":" '{print $2 ":" $3}' | sed 's/,*$//')
    nvme2=$(udevadm info --query path --name nvme2n1 | awk -F "\/" '{print $4 ":" $5 }' | awk -F ":" '{print $2 ":" $3}' | sed 's/,*$//')
    nvme3=$(udevadm info --query path --name nvme3n1 | awk -F "\/" '{print $4 ":" $5 }' | awk -F ":" '{print $2 ":" $3}' | sed 's/,*$//')
    patchnvmecache
}

patchnvmecache () {
    echo "NVMe Cache Init started"
    rm /etc.defaults/extensionPorts
    touch /etc.defaults/extensionPorts
    chmod 755 /etc.defaults/extensionPorts
    echo "[pci]" >> /etc.defaults/extensionPorts
    if [ -n "$nvme0" ]; then
    echo "Nvme Cache 1 found"
    echo "pci1=\"0000:$nvme0\"" >> /etc.defaults/extensionPorts
    echo "Nvme Location 1 = 0000:$nvme0"
    else
    echo "Nvme Location 1 not found"
    fi
    if [ -n "$nvme1" ]; then
    echo "Nvme Cache 2 found"
    echo "pci2=\"0000:$nvme1\"" >> /etc.defaults/extensionPorts
    echo "Nvme Location 2 = 0000:$nvme1"
    else
    echo "Nvme Location 2 not found"
    fi
    if [ -n "$nvme2" ]; then
    echo "Nvme Cache 3 found"
    echo "pci3=\"0000:$nvme2\"" >> /etc.defaults/extensionPorts
    echo "Nvme Location 3 = 0000:$nvme2"
    else
    echo "Nvme Location 3 not found"
    fi
    if [ -n "$nvme3" ]; then
    echo "Nvme Cache 4 found"
    echo "pci4=\"0000:$nvme3\"" >> /etc.defaults/extensionPorts
    echo "Nvme Location 4 = 0000:$nvme3"
    else
    echo "Nvme Location 4 not found"
    fi
echo "Nvme Cache Init successfull"
}

getnvmecache