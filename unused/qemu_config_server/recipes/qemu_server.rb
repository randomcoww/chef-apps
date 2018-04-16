[
  node['qemu']['config_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

node['qemu']['configs'].each do |guest, config|
  file ::File.join(node['qemu']['config_path'], guest) do
    content config
    action :create
  end
end
