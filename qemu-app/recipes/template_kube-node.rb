# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '10min'

node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[minikube-pod::pod_minikube]",
  "recipe[kubernetes-app::master]",
]

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 4

node.default['qemu']['current_config']['packages'] = [
  'glusterfs-client',
  'git',
  'socat'
]

node.default['qemu']['current_config']['runcmd'] = [
  'wget -O /tmp/etcd.tar.gz https://github.com/coreos/etcd/releases/download/v3.2.4/etcd-v3.2.4-linux-amd64.tar.gz',
  'tar xzf /tmp/etcd.tar.gz --wildcards --strip-components=1 -C /usr/local/bin */etcdctl */etcd',
  'wget -O /tmp/flannel.tar.gz https://github.com/coreos/flannel/releases/download/v0.8.0/flannel-v0.8.0-linux-amd64.tar.gz',
  "tar xzf /tmp/flannel.tar.gz -C /usr/local/bin 'flanneld'",
  'wget -O /tmp/cni-plugins.tar.gz https://github.com/containernetworking/plugins/releases/download/v0.6.0-rc1/cni-plugins-amd64-v0.6.0-rc1.tgz',
  'mkdir -p /opt/cni/bin/ && tar xzf /tmp/cni-plugins.tar.gz -C /opt/cni/bin'
]

include_recipe "qemu-app::_cloud_config_common"
# include_recipe "qemu-app::_libvirt_common"

node.default['qemu']['current_config']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['current_config']['hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"MiB"
      },
      "#text"=>node['qemu']['current_config']['memory']
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"MiB"
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
    "sysinfo"=>{
      "#attributes"=>{
        "type"=>"smbios"
      },
      "baseBoard"=>{
        "entry"=>{
          "#attributes"=>{
            "name"=>"serial"
          },
          "#text"=>"ds=nocloud"
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
      },
      "smbios"=>{
        "#attributes"=>{
          "mode"=>"sysinfo"
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
            "file"=>"/data/kvm/#{node['qemu']['current_config']['hostname']}.qcow2"
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
              "dir"=>"/data/secret/chef"
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
            "type"=>"network"
          },
          "source"=>{
            "#attributes"=>{
              "network"=>node['qemu']['libvirt_network_lan']
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
            "type"=>"network"
          },
          "source"=>{
            "#attributes"=>{
              "network"=>node['qemu']['libvirt_network_store']
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

include_recipe "qemu-app::_systemd_eth0_static"
include_recipe "qemu-app::_systemd_eth1_static"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
