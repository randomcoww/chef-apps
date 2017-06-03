# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[glusterfs-app::peer]",
  "recipe[keepalived-app::gluster]"
]

node.default['qemu']['current_config']['memory'] = 32
node.default['qemu']['current_config']['vcpu'] = 3

node.default['qemu']['current_config']['runcmd'] = [
]

include_recipe "qemu-app::_cloud_config_common"

node.default['qemu']['current_config']['systemd_config'] = {
  '/etc/systemd/network/eth0.network' => {
    "Match" => {
      "Name" => "eth0"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "DNS" => [
        node['environment_v2']['set']['dns']['vip_lan'],
        "8.8.8.8"
      ]
    },
    "Address" => {
      "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
    },
    "Route" => {
      "Gateway" => node['environment_v2']['set']['gateway']['vip_lan']
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
      "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_store']}/#{node['environment_v2']['subnet']['store'].split('/').last}"
    }
  },
  '/etc/systemd/system/chef-client.service' => {
    "Unit" => {
      "Description" => "Chef Client daemon",
      "After" => "network.target auditd.service"
    },
    "Service" => {
      "Type" => "oneshot",
      "ExecStart" => "/usr/bin/chef-client -o #{node['qemu']['current_config']['chef_recipes'].join(',')}",
      "ExecReload" => "/bin/kill -HUP $MAINPID",
      "SuccessExitStatus" => 3
    }
  },
  '/etc/systemd/system/chef-client.timer' => {
    "Unit" => {
      "Description" => "chef-client periodic run"
    },
    "Install" => {
      "WantedBy" => "timers.target"
    },
    "Timer" => {
      "OnStartupSec" => "1min",
      "OnUnitActiveSec" => node['qemu']['current_config']['chef_interval']
    }
  }
}

node.default['qemu']['current_config']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['current_config']['hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>node['qemu']['current_config']['memory']
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"GiB"
      },
      "#text"=>node['qemu']['current_config']['memory']
    },
    "vcpu"=>{
      "#attributes"=>{
        "placement"=>"static"
      },
      "#text"=>node['qemu']['current_config']['vcpu']
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
          "cores"=>node['qemu']['current_config']['vcpu'],
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
            "file"=>"/img/kvm/#{node['qemu']['current_config']['hostname']}.qcow2"
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
              "dir"=>node['qemu']['current_config']['cloud_config_path']
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
        },
        {
          "#attributes"=>{
            "type"=>"direct",
            "trustGuestRxFilters"=>"yes"
          },
          "source"=>{
            "#attributes"=>{
              "dev"=>node['environment_v2']['current_host']['if_store'],
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
                "domain"=>node['environment_v2']['current_host']['passthrough_hba']['domain'],
                "bus"=>node['environment_v2']['current_host']['passthrough_hba']['bus'],
                "slot"=>node['environment_v2']['current_host']['passthrough_hba']['slot'],
                "function"=>node['environment_v2']['current_host']['passthrough_hba']['function'],
              }
            }
          },
          "rom"=>{
            "#attributes"=>{
              "file"=>node['environment_v2']['current_host']['passthrough_hba']['file']
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

include_recipe "qemu-app::_deploy_common"
