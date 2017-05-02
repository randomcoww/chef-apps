node.default['qemu']['mysql-mgm']['cloud_config_hostname'] = 'mysql-mgm'
node.default['qemu']['mysql-mgm']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['mysql-mgm']['cloud_config_hostname']}"

node.default['qemu']['mysql-mgm']['networking'] = {
  '/etc/systemd/network/eth0.network' => {
    "Match" => {
      "Name" => "eth0"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "DNS" => [
        node['environment_v2']['vip']['dns_lan'],
        "8.8.8.8"
      ]
    },
    "Address" => {
      "Address" => "#{node['environment_v2']['host']['mysql-mgm']['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
    },
    "Route" => {
      "Gateway" => node['environment_v2']['vip']['gateway_lan']
    }
  }
}

node.default['qemu']['mysql-mgm']['chef_recipes'] = [
  "recipe[mysql-cluster-app::mgm]"
]
node.default['qemu']['mysql-mgm']['cloud_config'] = {
  "write_files" => [],
  "password" => "password",
  "chpasswd" => {
    "expire" => false
  },
  "ssh_pwauth" => false,
  "package_upgrade" => true,
  "apt_upgrade" => true,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['mysql-mgm']['cloud_config_hostname']}.lan",
  "runcmd" =>  [
    "echo deb http://repo.mysql.com/apt/debian/ jessie mysql-cluster-7.5 >> /etc/apt/sources.list.d/mysql.list",
    "echo deb-src http://repo.mysql.com/apt/debian/ jessie mysql-cluster-7.5 >> /etc/apt/sources.list.d/mysql.list",
    [
      "chef-client", "-o",
      node['qemu']['mysql-mgm']['chef_recipes'].join(',')
    ]
  ]
}


node.default['qemu']['mysql-mgm']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['mysql-mgm']['cloud_config_hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"1"
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"1"
    },
    "vcpu"=>{
      "#attributes"=>{
        "placement"=>"static"
      },
      "#text"=>"1"
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
          "cores"=>"1",
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
            "file"=>"/img/kvm/#{node['qemu']['mysql-mgm']['cloud_config_hostname']}.qcow2"
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
              "dir"=>node['qemu']['mysql-mgm']['cloud_config_path']
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
            "type"=>"direct",
            "trustGuestRxFilters"=>"yes"
          },
          "source"=>{
            "#attributes"=>{
              "dev"=>node['environment_v2']['current_host']['if_lan'],
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
