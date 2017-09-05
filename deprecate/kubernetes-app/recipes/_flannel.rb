systemd_unit "flannel.service" do
  content node['kubernetes']['flannel']['systemd_unit']
  action [:create]
end

service "flannel" do
  ignore_failure true
  action [:enable, :start]
end
