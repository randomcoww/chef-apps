systemd_unit 'kube-proxy.service' do
  content node['kube_master']['kube_proxy']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
