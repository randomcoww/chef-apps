kea_config 'kea-cql' do
  config node['kea']['cql']['kea_config']
  path ::File.join(Chef::Config[:file_cache_path], 'kea-cql')
  action :create
  notifies :reload, "docker_container[kea-cql]", :delayed
end

docker_image 'randomcoww/kea-cql' do
  action :pull_if_missing
  read_timeout 600
  # notifies :restart, "docker_container[kea-cql]", :delayed
end

docker_container 'kea-cql' do
  repo 'randomcoww/kea-cql'
  volumes [ "#{::File.join(Chef::Config[:file_cache_path], 'kea-cql')}:/etc/kea/kea-cql.conf" ]
  command "-c /etc/kea/kea-cql.conf"
  network_mode 'host'
  restart_policy 'unless-stopped'
  action :run
end
