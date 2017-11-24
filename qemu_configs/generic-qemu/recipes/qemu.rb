# guest -> host
guests = {}

node['environment_v2']['host'].each do |h, v|
  if v.has_key?('guests') && v['guests'].is_a?(Array)
    v['guests'].each do |g|
      guests[g] = h
    end
  end
end


guests.values.uniq.each do |host|
  [
    "if_lan",
    'if_store',
    "if_wan",
  ].each do |i|

    if_name = node['environment_v2']['host'][host][i]
    if !if_name.nil?

      node.default['qemu']['configs']["net-#{host}-#{i}"] = LibvirtConfig::ConfigGenerator.generate_from_hash({
        "network"=>{
          "name"=>i,
          "forward"=>{
            "#attributes"=>{
              "mode"=>"hostdev",
              "managed"=>"yes"
            },
            "pf"=>{
              "#attributes"=>{
                "dev"=>if_name
              }
            },
            "driver"=>{
              "#attributes"=>{
                "name"=>"vfio"
              }
            }
          }
        }
      })
    end
  end
end


guests.each do |guest, host|

  host_config = node['environment_v2']['host'][host]
  guest_config = node['environment_v2']['host'][guest]

  memory = guest_config['memory']
  vcpu = guest_config['vcpu']

  networks = []

  [
    ['if_lan', 'mac_lan'],
    ['if_store', 'mac_store'],
    ['if_wan', 'mac_wan']
  ].each do |if_key, mac|

    if guest_config.has_key?(if_key) &&
      host_config.has_key?(if_key)

      mac_hash = {}
      if guest_config.has_key?(mac)
        mac_hash = {
          "mac"=>{
            "#attributes"=>{
              "address"=>guest_config[mac]
            }
          }
        }
      end

      ## sriov
      # networks << {
      #   "#attributes"=>{
      #     "type"=>"network"
      #   },
      #   "source"=>{
      #     "#attributes"=>{
      #       "network"=>if_key
      #     }
      #   },
      #   "model"=>{
      #     "#attributes"=>{
      #       "type"=>"virtio-net"
      #     }
      #   }
      # }.merge(mac_hash)

      ## macvtap
      networks << {
        "#attributes"=>{
          "type"=>"direct",
          "trustGuestRxFilters"=>"yes"
        },
        "source"=>{
          "#attributes"=>{
            "dev"=>host_config[if_key],
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


  node.default['qemu']['configs'][guest] = LibvirtConfig::ConfigGenerator.generate_from_hash({
    "domain"=>{
      "#attributes"=>{
        "type"=>"kvm"
      },
      "name"=>guest,
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
            "coreos.config.url=#{node['environment_v2']['url']['ignition']}/#{guest}",
            "net.ifnames=0",
            "console=hvc0",
            "elevator=noop"
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
        # "serial"=>{
        #   "#attributes"=>{
        #     "type"=>"pty"
        #   },
        #   "target"=>{
        #     "#attributes"=>{
        #       "port"=>"0"
        #     }
        #   }
        # },
        "channel"=>{
          "#attributes"=>{
            "type"=>"spicevmc"
          },
          "target"=>{
            "#attributes"=>{
              "type"=>"virtio",
              "name"=>"com.redhat.spice.0"
            }
          }
        },
        "console"=>{
          "#attributes"=>{
            "type"=>"pty"
          },
          "target"=>{
            "#attributes"=>{
              "type"=>"virtio",
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
