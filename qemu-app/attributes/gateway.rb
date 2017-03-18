node.default['qemu']['gateway']['cloud_config_hostname'] = 'gateway'
node.default['qemu']['gateway']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['gateway']['cloud_config_hostname']}"
node.default['qemu']['gateway']['networking'] = {
  '/etc/systemd/network/eth0.network' => {
    "Match" => {
      "Name" => "eth0"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "Address" => node['environment']['gateway_ip']
    }
  },
  '/etc/systemd/network/eth1.network' => {
    "Match" => {
      "Name" => "eth1"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "Bridge" => "brvpn"
    }
  },
  '/etc/systemd/network/tap.network' => {
    "Match" => {
      "Name" => "tap*"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
      "Bridge" => "brvpn"
    }
  },
  '/etc/systemd/network/brvpn.netdev' => {
    "NetDev" => {
      "Kind" => "bridge",
      "Name" => "brvpn"
    }
  },
  '/etc/systemd/network/brvpn.network' => {
    "Match" => {
      "Name" => "brvpn"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "no",
    }
  },
  '/etc/systemd/network/eth2.network' => {
    "Match" => {
      "Name" => "eth2"
    },
    "Network" => {
      "LinkLocalAddressing" => "no",
      "DHCP" => "yes",
      "DNS" => [
        "127.0.0.1",
        "8.8.8.8"
      ]
    },
    "DHCP" => {
      "UseDNS" => "false",
      "UseNTP" => "false",
      "SendHostname" => "false",
      "UseHostname" => "false",
      "UseDomains" => "false",
      "UseTimezone" => "no"
    }
  }
}

node.default['qemu']['gateway']['chef_recipes'] = [
  "nftables-app::gateway",
  "kea-app::dhcp4",
  "nsd-app::main",
  "unbound-app::main",
  "keepalived-app::gateway"
]
node.default['qemu']['gateway']['cloud_config'] = {
  "write_files" => [],
  "password" => "password",
  "chpasswd" => {
    "expire" => false
  },
  "ssh_pwauth" => false,
  "package_upgrade" => true,
  "apt_upgrade" => true,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['gateway']['cloud_config_hostname']}.lan",
  "runcmd" => [
    [
      "chef-client", "-o",
      node['qemu']['gateway']['chef_recipes'].map { |e| "recipe[#{e}]" }.join(','),
      "-j", "/etc/chef/environment.json"
    ]
  ]
  # "ssh_authorized_keys" => [
  #   {
  #     "ssh-rsa" => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCf4YDpCaridIv8B4LIj8zYVbRfEgDvstlFu4nllhfY9UEcoHgBHEDmCFe1+qsv3flxTm7Q5v4q6RIETS2AwzRTlSTyzcI6t8jQ16R6aoLcbU2J2kWsD/rGHAuHGtZb2950rApIfOdP4n05uW34We6ErZmlCC0R/x9JIP5QqvoJE9KaVC3v/vPG1KVsYZFxtyKVHnFwwPlzjtHp+Tq0xG7jCPG5w+fekpvcImxo8isunRkpyHQFRE0nQAlIfCmJ1LdG3PREswuinKHiW33hXqkRVCSXmF2PGLW+x9aWvcMgbguX9WGWO4Dafta2lzwN6x4QWmc6bQpO1akw3Qi5rzQN"
  #   }
  # ]
}


node.default['qemu']['gateway']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>"dns",
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
            "file"=>"/img/kvm/gateway.qcow2"
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
              "dir"=>node['qemu']['gateway']['cloud_config_path']
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
            "type"=>"bridge"
          },
          "source"=>{
            "#attributes"=>{
              "bridge"=>"brlan"
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
            "type"=>"bridge"
          },
          "source"=>{
            "#attributes"=>{
              "bridge"=>"brvpn"
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
            "type"=>"bridge"
          },
          "mac"=>{
            "#attributes"=>{
              "address"=>node['environment']['wan_mac']
            }
          },
          "source"=>{
            "#attributes"=>{
              "bridge"=>"brwan"
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
