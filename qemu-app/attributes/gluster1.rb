node.default['qemu']['gluster1']['cloud_config_hostname'] = 'gluster1'
node.default['qemu']['gluster1']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['gluster1']['cloud_config_hostname']}"

node.default['qemu']['gluster1']['networking'] = {
  '/etc/systemd/network/eth0.network' => {
    "Match" => {
      "Name" => "eth0"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "DNS" => [
        node['environment_v2']['lb_lan_vip'],
        "8.8.8.8"
      ]
    },
    "Address" => {
      "Address" => "#{node['environment_v2']['gluster1_lan_ip']}/#{node['environment_v2']['lan_subnet'].split('/').last}"
    },
    "Route" => {
      "Gateway" => node['environment_v2']['gateway_lan_vip']
    }
  },
  '/etc/systemd/network/eth1.network' => {
    "Match" => {
      "Name" => "eth1"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
    },
    "Address" => {
      "Address" => "#{node['environment_v2']['gluster1_store_ip']}/#{node['environment_v2']['store_subnet'].split('/').last}"
    }
  }
}

node.default['qemu']['gluster1']['chef_recipes'] = [
  "recipe[keepalived-app::gluster]"
]
node.default['qemu']['gluster1']['cloud_config'] = {
  "write_files" => [],
  "password" => "password",
  "chpasswd" => {
    "expire" => false
  },
  "ssh_pwauth" => false,
  "package_upgrade" => true,
  "apt_upgrade" => true,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['gluster1']['cloud_config_hostname']}.lan",
  "runcmd" => [
    "apt-get -y install glusterfs-server",
    [
      "chef-client", "-o",
      node['qemu']['gluster1']['chef_recipes'].join(',')
    ]
  ]
}


node.default['qemu']['gluster1']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['gluster1']['cloud_config_hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"32"
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>"32"
    },
    "vcpu"=>{
      "#attributes"=>{
        "placement"=>"static"
      },
      "#text"=>"4"
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
          "cores"=>"4",
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
            "file"=>"/img/kvm/#{node['qemu']['gluster1']['cloud_config_hostname']}.qcow2"
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
              "dir"=>node['qemu']['gluster1']['cloud_config_path']
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
            "type"=>"direct",
            "trustGuestRxFilters"=>"yes"
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
      "hostdev" => [
        {
          "#attributes"=>{
            "mode"=>"subsystem",
            "type"=>"pci",
            "managed"=>"yes"
          },
          "driver"=>{
            "#attributes"=>{
              "name"=>"vfio"
            }
          },
          "source"=>{
            "address"=>{
              "#attributes"=>{
                "domain"=>node['environment_v2']['hba_source']['domain'],
                "bus"=>node['environment_v2']['hba_source']['bus'],
                "slot"=>node['environment_v2']['hba_source']['slot'],
                "function"=>node['environment_v2']['hba_source']['function'],
              }
            }
          },
          "rom"=>{
            "#attributes"=>{
              "file"=>node['environment_v2']['hba_source']['file']
            }
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
