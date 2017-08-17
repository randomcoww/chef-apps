systemd_resource_dropin "10-dropin" do
  service "docker.service"
  config node['kubernetes']['docker']['systemd_dropin']
  action [:create]
end

service "docker" do
  ignore_failure true
  action [:enable, :start]
end
