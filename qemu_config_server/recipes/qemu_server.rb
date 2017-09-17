[
  node['qemu']['config_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

node['qemu']['configs'].each do |host, config|

  file ::File.join(node['qemu']['config_path'], host) do
    content config
    action :create
  end

end
