kea_config = ::File.join(Chef::Config[:file_cache_path], 'kea-cql.conf')

docker_image 'randomcoww/kea-cql' do
  action :pull_if_missing
  read_timeout 600
  # notifies :restart, "docker_container[kea-cql]", :delayed
end

kea_config 'kea-cql' do
  config node['kea']['cql']['kea_config']
  path kea_config
  action :create
  notifies :restart, "docker_container[kea-cql]", :immediately
end

docker_container 'kea-cql' do
  repo 'randomcoww/kea-cql'
  volumes [
    "#{kea_config}:/etc/kea/kea-cql.conf",
  ]
  command "kea-dhcp4 -c /etc/kea/kea-cql.conf"
  network_mode 'host'
  restart_policy 'unless-stopped'
  action :run
end
