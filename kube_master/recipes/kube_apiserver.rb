systemd_unit 'kube-apiserver.service' do
  content node['kube_master']['kube_apiserver']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
