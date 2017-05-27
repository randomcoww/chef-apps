apt_package node['kube_master']['docker']['pkg_names'] do
  action :install
  options [
    '--no-install-recommends',
    '--allow-unauthenticated'
  ]
  notifies :stop, "service[docker]", :immediately
end

systemd_resource_dropin "10-flannel" do
  service "docker.service"
  config node['kube_master']['docker']['systemd_dropin']
  action [:create]
end

service "docker" do
  ignore_failure true
  action [:enable, :start]
end
