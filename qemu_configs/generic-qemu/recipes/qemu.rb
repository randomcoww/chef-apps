node['qemu']['generic']['hosts'].each do |host, config|

  host_config = node['environment_v2']['host'][host]
  memory = host_config['memory']
  vcpu = host_config['vcpu']


  networks = []

  [
    ['if_lan', 'mac_lan'],
    ['if_store', 'mac_store'],
    ['if_wan', 'mac_wan']
  ].each do |if_key, mac|

    if host_config.has_key?(if_key)

      mac_hash = {}
      if host_config.has_key?(mac)
        mac_hash = {
          "mac"=>{
            "#attributes"=>{
              "address"=>host_config[mac]
            }
          }
        }
      end

      networks << {
        "#attributes"=>{
          "type"=>"direct",
          "trustGuestRxFilters"=>"yes"
        },
        "source"=>{
          "#attributes"=>{
            "dev"=>node['environment_v2']['node_host'][if_key],
            "mode"=>"bridge"
          }
        },
        "model"=>{
          "#attributes"=>{
            "type"=>"virtio-net"
          }
        }
      }.merge(mac_hash)
    end
  end


  node.default['qemu']['configs'][host] = LibvirtConfig::ConfigGenerator.generate_from_hash({
    "domain"=>{
      "#attributes"=>{
        "type"=>"kvm"
      },
      "name"=>host,
      "memory"=>{
        "#attributes"=>{
          "unit"=>"MiB"
        },
        "#text"=>memory
      },
      "currentMemory"=>{
        "#attributes"=>{
          "unit"=>"MiB"
        },
        "#text"=>memory
      },
      "vcpu"=>{
        "#attributes"=>{
          "placement"=>"static"
        },
        "#text"=>vcpu
      },
      # "iothreads"=>"1",
      # "iothreadids"=>{
      #   "iothread"=>{
      #     "#attributes"=>{
      #       "id"=>"1"
      #     }
      #   }
      # },
      "os"=>{
        "type"=>{
          "#attributes"=>{
            "arch"=>"x86_64",
            "machine"=>"pc"
          },
          "#text"=>"hvm"
        },
        "kernel"=>{
          "#text"=>node['qemu']['pxe_kernel_path']
        },
        "initrd"=>{
          "#text"=>node['qemu']['pxe_initrd_path']
        },
        "cmdline"=>{
          "#text"=>[
            "coreos.first_boot=1",
            "console=ttyS0",
            "coreos.config.url=#{node['environment_v2']['url']['ignition']}/#{host}",
          ].join(' '),
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
            "cores"=>vcpu,
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
        "interface"=>networks,
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
  })

end
