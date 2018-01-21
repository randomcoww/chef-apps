[
  node['kickstart']['config_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


subnet = node['environment_v2']['subnet']

node['environment_v2']['set']['mgm']['hosts'].each do |host|

  interfaces = node['environment_v2']['host'][host]['if']
  ips = node['environment_v2']['host'][host]['ip']

  networks = {
    "#{interfaces['store']}.network" => {
      "Match" => {
        "Name" => interfaces['store']
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "yes",
      },
      "Address" => {
        "Address" => "#{ips['store']}/#{subnet['store'].split('/').last}"
      }
    },

  }

  template ::File.join(node['kickstart']['config_path'], "#{host}.ks") do
    source 'kickstart.erb'
    variables ({
      hostname: host,
      username: node['kickstart']['mgm']['username'],
      password: node['kickstart']['mgm']['password'],
      groups: node['kickstart']['mgm']['groups'],
      sshkeys: node['kickstart']['mgm']['sshkeys'],
      boot_params: node['kickstart']['mgm']['boot_params'],
      packages_install: node['kickstart']['mgm']['packages_install'],
      packages_remove: node['kickstart']['mgm']['packages_remove'],
      services_enable: node['kickstart']['mgm']['services_enable'],
      networks: networks
    })
  end

end
