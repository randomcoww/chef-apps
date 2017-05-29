systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
