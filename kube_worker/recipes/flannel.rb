package node['kube_worker']['flannel']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[flannel]", :immediately
end

systemd_unit "flannel.service" do
  content node['kube_worker']['flannel']['systemd_unit']
  action [:create]
end

service "flannel" do
  ignore_failure true
  action [:enable, :start]
end
