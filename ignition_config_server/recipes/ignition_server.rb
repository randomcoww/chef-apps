node['ignition']['configs'].each do |host, config|

  if config.is_a?(Hash)
    config_path = ::File.join(node['ignition']['config_path'], host)

    ignition_config config_path do
      version node['ignition']['version']
      base config['base']
      files config['files']
      networkd config['networkd']
      systemd config['systemd']
      path config_path
      action :create
    end
  end

end
