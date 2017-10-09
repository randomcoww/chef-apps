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

  node['qemu'][current_host]['guests'].each do |host|
    if node['qemu']['configs'].has_key?(host)
      file ::File.join(node['qemu']['config_path'], host) do
        content node['qemu']['configs'][host]
        action :create
      end
    end
  end

end
