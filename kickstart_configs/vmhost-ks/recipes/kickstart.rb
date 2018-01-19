[
  node['kickstart']['config_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


node['environment_v2']['set']['vmhost']['hosts'].each do |host|

  interfaces = node['environment_v2']['host'][host]['if']
  ips = node['environment_v2']['host'][host]['ip']

  networks = {
    ## lan network
    "#{interfaces['lan']}.network" => {
      "Match" => {
        "Name" => interfaces['lan']
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "no",
        "VLAN" => "wan"
      }
    },

    ## store
    "#{interfaces['store']}.network" => {
      "Match" => {
        "Name" => interfaces['store']
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "no",
        "MACVLAN" => "#{interfaces['store']}_host"
      },
    },

    ## allow guests to access the host over macvlan
    "#{interfaces['store']}_host.netdev" => {
      "NetDev" => {
        "Name" => "#{interfaces['store']}_host",
        "Kind" => "macvlan"
      },
      "MACVLAN" => {
        "Mode" => "bridge"
      }
    },

    "#{interfaces['store']}_host.network" => {
      "Match" => {
        "Name" => "#{interfaces['store']}_host"
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "yes",
      },
      "Address" => {
        "Address" => ips['store']
      }
    },

    ## wan
    "#{interfaces['wan']}.netdev" => {
      "NetDev" => {
        "Name" => interfaces['wan'],
        "Kind" => "vlan"
      },
      "VLAN" => {
        "Id" => 30
      }
    },

    "#{interfaces['wan']}.network" => {
      "Match" => {
        "Name" => interfaces['wan']
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "no",
      }
    },

    ## zfssync
    "#{interfaces['zfssync']}.network" => {
      "Match" => {
        "Name" => interfaces['zfssync']
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "no",
      },
      "Address" => {
        "Address" => ips['zfssync']
      }
    }

  }

  template ::File.join(node['kickstart']['config_path'], "#{host}.ks") do
    source 'kickstart.erb'
    variables ({
      hostname: host,
      username: node['kickstart']['vmhost']['username'],
      password: node['kickstart']['vmhost']['password'],
      groups: node['kickstart']['vmhost']['groups'],
      sshkeys: node['kickstart']['vmhost']['sshkeys'],
      boot_params: node['kickstart']['vmhost']['boot_params'],
      packages_install: node['kickstart']['vmhost']['packages_install'],
      packages_remove: node['kickstart']['vmhost']['packages_remove'],
      services_enable: node['kickstart']['vmhost']['services_enable'],
      module_options: node['kickstart']['vmhost']['module_options'],
      systemd_units: node['kickstart']['vmhost']['systemd_units'],
      networks: networks
    })
  end

end
