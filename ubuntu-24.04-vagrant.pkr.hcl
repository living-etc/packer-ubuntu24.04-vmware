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

source "vmware-vmx" "ubuntu-2404-vagrant" {
  vm_name       = local.vm_name
  headless      = false

  source_path = "build/ubuntu-24.04-vmx/ubuntu-24.04.vmx"

  disk_adapter_type  = "nvme"

  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_pty = true
  ssh_timeout = "20m"
  ssh_handshake_attempts = "20000"

  shutdown_command = "sudo shutdown -P now"

  output_directory = "build/${local.vm_name}-vagrant"
}

locals {
  version = formatdate("YYYYMMDDhhmmss", timestamp())
  vm_name = "ubuntu-24.04"
}

build {
  sources = ["sources.vmware-vmx.ubuntu-2404-vagrant"]

  provisioner "shell" {
    inline = [
      "sudo useradd vagrant",
      "id -u vagrant &>/dev/null || sudo useradd -g vagrant -m vagrant",
      "echo vagrant:vagrant | sudo chpasswd",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      include = [
        "build/ubuntu-24.04-vmx/disk-s001.vmdk",
        "build/ubuntu-24.04-vmx/disk-s002.vmdk",
        "build/ubuntu-24.04-vmx/disk-s003.vmdk",
        "build/ubuntu-24.04-vmx/disk-s004.vmdk",
        "build/ubuntu-24.04-vmx/disk-s005.vmdk",
        "build/ubuntu-24.04-vmx/disk.vmdk",
        "build/ubuntu-24.04-vmx/${local.vm_name}.nvram",
        "build/ubuntu-24.04-vmx/${local.vm_name}.vmsd",
        "build/ubuntu-24.04-vmx/${local.vm_name}.vmx",
        "build/ubuntu-24.04-vmx/${local.vm_name}.vmxf",
      ]
      output               = "living-etc/${local.vm_name}.box"
      vagrantfile_template = "Vagrantfile"
    }

    post-processor "vagrant-cloud" {
      box_tag = "living-etc/${local.vm_name}"
      version = "${local.version}"
    }
  }
}
