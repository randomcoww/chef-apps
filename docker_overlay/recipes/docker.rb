package node['docker_overlay']['docker']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[docker]", :immediately
end

systemd_resource_dropin "10-flannel" do
  service "docker.service"
  config node['docker_overlay']['docker']['systemd_dropin']
  action [:create]
end

service "docker" do
  ignore_failure true
  action [:enable, :start]
end
