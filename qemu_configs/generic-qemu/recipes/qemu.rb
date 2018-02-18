# guest -> host
guests = {}

node['environment_v2']['host'].each do |h, v|
  if v.has_key?('guests') && v['guests'].is_a?(Array)
    v['guests'].each do |g|
      guests[g] = h
    end
  end
end


guests.each do |guest, host|

  host_config = node['environment_v2']['host'][host]
  next if !host_config['if'].is_a?(Hash)

  ## sriov networks
  host_config['if'].each do |i, interface|
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
              "dev"=>interface
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


  guest_config = node['environment_v2']['host'][guest]

  memory = guest_config['memory']
  vcpu = guest_config['vcpu']

  networks = []

  # kernel boot option
  ignition_ip_config = []

  if guest_config['if'].is_a?(Hash) &&
    guest_config['if_type'].is_a?(Hash)

    ##
    ## consistent interface names in VM
    ##
    ## this becomes interface "ens#{hardware_slot_index}" in guest with sriov
    ## make sure nics are always 2, 3, 4.. in order they are configured
    hardware_slot_index = 2

    # add static config to ignition if static ip configured
    # skip if there are any dhcp configured interfaces
    use_ignition_ip_config = guest_config['ip'].is_a?(Hash) &&
        guest_config['ip'].length == guest_config['if'].length


    guest_config['if'].each do |i, interface|

      next if host_config['if'][i].nil?

      ##
      ## if static ip
      ##
      if use_ignition_ip_config &&
        !guest_config['ip'][i].nil?

        ignition_ip_config << "ip=" + [
          guest_config['ip'][i],
          '',
          node['environment_v2']['set']['gateway']['vip'][i],
          node['environment_v2']['netmask'][i],
          '',
          guest_config['if'][i],
          'none',
          node['environment_v2']['set']['dns']['vip'][i],
          '8.8.8.8',
        ].join(':')
      end

      ##
      ## mac if provided
      ##
      mac_hash = {}
      if guest_config['mac'].is_a?(Hash) &&
        !guest_config['mac'][i].nil?

        mac_hash = {
          "mac"=>{
            "#attributes"=>{
              "address"=>guest_config['mac'][i]
            }
          }
        }
      end

      ##
      ## vm slot address
      ##
      address_hash = {
        "address"=>{
          "#attributes"=>{
            'type'=>'pci',
            'domain'=>0,
            'bus'=>0,
            'slot'=>hardware_slot_index,
            'function'=>0,
          }
        }
      }

      hardware_slot_index += 1

      ##
      ## host nic type sriov or macvlan
      ##
      case guest_config['if_type'][i]
      when 'sriov'
        ## sriov
        networks << {
          "#attributes"=>{
            "type"=>"network"
          },
          "source"=>{
            "#attributes"=>{
              "network"=>i
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        }.merge(mac_hash).merge(address_hash)

      when 'macvlan'
        ## macvtap
        networks << {
          "#attributes"=>{
            "type"=>"direct",
            "trustGuestRxFilters"=>"yes"
          },
          "source"=>{
            "#attributes"=>{
              "dev"=>host_config['if'][i],
              "mode"=>"bridge"
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        }.merge(mac_hash).merge(address_hash)

      end
    end
  end


  node.default['qemu']['configs']["#{host}-#{guest}"] = LibvirtConfig::ConfigGenerator.generate_from_hash({
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
          "#text"=>([
            "coreos.first_boot=1",
            "coreos.config.url=#{node['environment_v2']['url']['ignition']}/#{guest}",
            # "net.ifnames=0",
            "console=hvc0",
            "elevator=noop",
          ] + ignition_ip_config).join(' '),
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
