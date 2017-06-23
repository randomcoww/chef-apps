include_recipe "kubernetes-app::_docker"

package node['kubernetes']['packages'] do
  action :install
end


[
  'kubelet',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0750'
    action :create_if_missing
  end
end

[
  node['kubernetes']['manifests_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


## kubelet
systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end

include_recipe "kubernetes-app::_static_pods"
