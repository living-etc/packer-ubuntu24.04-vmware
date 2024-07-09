packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "ubuntu-2404-iso" {
  vm_name       = local.vm_name
  guest_os_type = "arm-ubuntu-64"
  version       = 20
  headless      = false
  memory        = 8172
  cpus          = 2
  cores         = 2
  disk_size     = 20000
  sound         = false
  usb           = true

  network              = "nat"
  network_adapter_type = "e1000e"

  cdrom_adapter_type = "sata"
  disk_adapter_type  = "nvme"

  iso_url      = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04-live-server-arm64.iso"
  iso_checksum = "d2d9986ada3864666e36a57634dfc97d17ad921fa44c56eeaca801e7dab08ad7"

  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_pty = true
  ssh_timeout = "20m"
  ssh_handshake_attempts = "20000"

  shutdown_command = "sudo shutdown -P now"

  http_directory   = "http"
  output_directory = "build/${local.vm_name}-vmx"

  boot_wait    = "5s"
  boot_command = [
    "c<wait>",
    "set gfxpayload=keep<enter><wait>",
    "linux /casper/vmlinuz<spacebar>",
    "autoinstall quiet<spacebar>",
    "ds=\"nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<spacebar>",
    "---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
  ]
}

locals {
  version = formatdate("YYYYMMDDhhmmss", timestamp())
  vm_name = "ubuntu-24.04"
}

build {
  sources = ["sources.vmware-iso.ubuntu-2404-iso"]
}
