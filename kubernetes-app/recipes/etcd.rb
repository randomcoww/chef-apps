package node['kubernetes']['etcd']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[etcd]", :immediately
end

user node['kubernetes']['etcd']['user'] do
  shell '/bin/false'
  action :create
end

directory node['kubernetes']['etcd']['environment']['ETCD_DATA_DIR'] do
  owner node['kubernetes']['etcd']['user']
  recursive true
  action :create
end

systemd_unit "etcd.service" do
  content node['kubernetes']['etcd']['systemd_unit']
  action [:create]
end

service "etcd" do
  ignore_failure true
  action [:enable, :start]
end
