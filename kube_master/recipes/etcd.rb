package node['kube_master']['etcd']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[etcd]", :immediately
end

user node['kube_master']['etcd']['user'] do
  shell '/bin/false'
  action :create
end

directory node['kube_master']['etcd']['environment']['ETCD_DATA_DIR'] do
  owner node['kube_master']['etcd']['user']
  recursive true
  action :create
end

systemd_unit "etcd.service" do
  content node['kube_master']['etcd']['systemd_unit']
  action [:create]
end

service "etcd" do
  ignore_failure true
  action [:enable, :start]
end
