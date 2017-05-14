package node['docker_overlay']['etcd']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[etcd]", :immediately
end

user node['docker_overlay']['etcd']['user'] do
  shell '/bin/false'
  action :create
end

directory node['docker_overlay']['etcd']['environment']['ETCD_DATA_DIR'] do
  owner node['docker_overlay']['etcd']['user']
  recursive true
  action :create
end

systemd_unit "etcd.service" do
  content node['docker_overlay']['etcd']['systemd_unit']
  action [:create]
end

service "etcd" do
  ignore_failure true
  action [:enable, :start]
end
