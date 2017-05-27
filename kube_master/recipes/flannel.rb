package node['kube_master']['flannel']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[flannel]", :immediately
end

systemd_unit "flannel.service" do
  content node['kube_master']['flannel']['systemd_unit']
  action [:create]
end

service "flannel" do
  ignore_failure true
  action [:enable, :start]
end
