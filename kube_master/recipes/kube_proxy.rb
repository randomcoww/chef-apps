systemd_unit 'kube-proxy.service' do
  content node['kube_master']['kube_proxy']['systemd']
  action [:create, :enable, :start]
end
