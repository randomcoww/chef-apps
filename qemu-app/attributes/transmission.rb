node.default['qemu']['transmission']['cloud_config_hostname'] = 'transmission'
node.default['qemu']['transmission']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['transmission']['cloud_config_hostname']}"

node.default['qemu']['transmission']['networking'] = {
  '/etc/systemd/network/eth0.network' => {
    "Match" => {
      "Name" => "eth0"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "yes"
    }
  },
  '/etc/systemd/network/eth1.network' => {
    "Match" => {
      "Name" => "eth1"
    },
    "Network" => {
      "LinkLocalAddressing" => "yes",
      "DHCP" => "no"
    }
  },
  '/etc/systemd/system/docker.service.d/log-driver.conf' => {
    "Service" => {
      "ExecStart" => [
        '',
        "/usr/bin/dockerd -H fd:// --log-driver=journald"
      ]
    }
  }
}

node.default['qemu']['transmission']['chef_recipes'] = [
  "recipe[nftables-app::filter]",
  "recipe[transmission-app::main]"
]
node.default['qemu']['transmission']['cloud_config'] = {
  "write_files" => [],
  "password" => "password",
  "chpasswd" => {
    "expire" => false
  },
  "ssh_pwauth" => false,
  "package_upgrade" => true,
  "apt_upgrade" => true,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['transmission']['cloud_config_hostname']}.lan",
  "runcmd" => [
    "apt-get -y install apt-transport-https ca-certificates gnupg2 dirmngr",
    "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D",
    "echo deb https://apt.dockerproject.org/repo debian-stretch main > /etc/apt/sources.list.d/docker.list",
    "apt-get -y update",
    "apt-get -y --allow-unauthenticated install docker-engine",
    "apt-get -y install glusterfs-client",
    [
      "chef-client", "-o",
      node['qemu']['transmission']['chef_recipes'].join(',')
    ],
    "docker run -d --restart unless-stopped -v /etc/chef:/etc/chef --net host --cap-add=NET_ADMIN --device /dev/net/tun randomcoww/chef-client:entrypoint -o recipe[openvpn-app::pia_client]"
  ]
}


node.default['qemu']['transmission']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['transmission']['cloud_config_hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"2"
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"2"
    },
    "vcpu"=>{
      "#attributes"=>{
        "placement"=>"static"
      },
      "#text"=>"2"
    },
    "iothreads"=>"1",
    "iothreadids"=>{
      "iothread"=>{
        "#attributes"=>{
          "id"=>"1"
        }
      }
    },
    "os"=>{
      "type"=>{
        "#attributes"=>{
          "arch"=>"x86_64",
          "machine"=>"pc"
        },
        "#text"=>"hvm"
      },
      "boot"=>{
        "#attributes"=>{
          "dev"=>"hd"
        }
      }
    },
    "features"=>{
      "acpi"=>"",
      "apic"=>"",
      "pae"=>""
    },
    "cpu"=>{
      "#attributes"=>{
        "mode"=>"host-passthrough"
      },
      "topology"=>{
        "#attributes"=>{
          "sockets"=>"1",
          "cores"=>"2",
          "threads"=>"1"
        }
      }
    },
    "clock"=>{
      "#attributes"=>{
        "offset"=>"utc"
      }
    },
    "on_poweroff"=>"destroy",
    "on_reboot"=>"restart",
    "on_crash"=>"restart",
    "devices"=>{
      "emulator"=>"/usr/bin/qemu-system-x86_64",
      "disk"=>{
        "#attributes"=>{
          "type"=>"file",
          "device"=>"disk"
        },
        "driver"=>{
          "#attributes"=>{
            "name"=>"qemu",
            "type"=>"qcow2",
            "iothread"=>"1"
          }
        },
        "source"=>{
          "#attributes"=>{
            "file"=>"/img/kvm/#{node['qemu']['transmission']['cloud_config_hostname']}.qcow2"
          }
        },
        "target"=>{
          "#attributes"=>{
            "dev"=>"vda",
            "bus"=>"virtio"
          }
        }
      },
      "controller"=>[
        {
          "#attributes"=>{
            "type"=>"usb",
            "index"=>"0",
            "model"=>"none"
          }
        },
        {
          "#attributes"=>{
            "type"=>"pci",
            "index"=>"0",
            "model"=>"pci-root"
          }
        }
      ],
      "filesystem"=>[
        {
          "#attributes"=>{
            "type"=>"mount",
            "accessmode"=>"squash"
          },
          "source"=>{
            "#attributes"=>{
              "dir"=>"/img/secret/chef"
            }
          },
          "target"=>{
            "#attributes"=>{
              "dir"=>"chef-secret"
            }
          },
          "readonly"=>""
        },
        {
          "#attributes"=>{
            "type"=>"mount",
            "accessmode"=>"squash"
          },
          "source"=>{
            "#attributes"=>{
              "dir"=>node['qemu']['transmission']['cloud_config_path']
            }
          },
          "target"=>{
            "#attributes"=>{
              "dir"=>"cloud-init"
            }
          },
          "readonly"=>""
        }
      ],
      "interface"=>[
        {
          "#attributes"=>{
            "type"=>"direct"
          },
          "source"=>{
            "#attributes"=>{
              "dev"=>node['environment_v2']['host_lan_if'],
              "mode"=>"bridge"
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        },
        {
          "#attributes"=>{
            "type"=>"direct"
          },
          "source"=>{
            "#attributes"=>{
              "dev"=>node['environment_v2']['host_store_if'],
              "mode"=>"bridge"
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        }
      ],
      "serial"=>{
        "#attributes"=>{
          "type"=>"pty"
        },
        "target"=>{
          "#attributes"=>{
            "port"=>"0"
          }
        }
      },
      "console"=>{
        "#attributes"=>{
          "type"=>"pty"
        },
        "target"=>{
          "#attributes"=>{
            "type"=>"serial",
            "port"=>"0"
          }
        }
      },
      "input"=>[
        {
          "#attributes"=>{
            "type"=>"mouse",
            "bus"=>"ps2"
          }
        },
        {
          "#attributes"=>{
            "type"=>"keyboard",
            "bus"=>"ps2"
          }
        }
      ],
      "memballoon"=>{
        "#attributes"=>{
          "model"=>"virtio"
        }
      }
    }
  }
}
