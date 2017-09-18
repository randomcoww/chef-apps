[
  node['qemu']['config_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


current_host = node['environment_v2']['node_name']
guests = node['qemu'][current_host]['guests']

if guests.is_a?(Array) && !guests.empty?

  content = []
  node['qemu'][current_host]['guests'].each do |host|
    content << {
      "name" => host,
      "contents" => node['qemu']['configs'][host]
    }
  end

  file ::File.join(node['qemu']['config_path'], current_host) do
    content content.to_yaml
    action :create
  end
end
