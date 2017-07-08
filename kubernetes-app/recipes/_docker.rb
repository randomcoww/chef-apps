apt_package node['kubernetes']['docker']['pkg_names'] do
  action :install
  options [
    '--no-install-recommends',
    # '--allow-unauthenticated'
  ]
  notifies :stop, "service[docker]", :immediately
end

systemd_resource_dropin "10-dropin" do
  service "docker.service"
  config node['kubernetes']['docker']['systemd_dropin']
  action [:create]
end

service "docker" do
  ignore_failure true
  action [:enable, :start]
end
