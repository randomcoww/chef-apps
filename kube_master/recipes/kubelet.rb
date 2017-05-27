directory node['kube_master']['ssl_path'] do
  recursive true
  action [:create]
end

kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kube_master']['ca_path']
  action :create
end

kubernetes_node_cert 'kubelet' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn 'kube-apiserver'
  key_path node['kube_master']['key_path']
  cert_path node['kube_master']['cert_path']
  alt_names ({
    'DNS.1' => 'kube_master',
    'DNS.2' => 'kubernetes.default',
    'DNS.3' => 'kubernetes.default.svc',
    'DNS.4' => 'kubernetes.default.svc.cluster.local',
    'IP.1' => node['kube_master']['node_ip'],
    'IP.2' => node['environment_v2']['set']['haproxy']['vip_lan'],
  })
  action :create_if_missing
end

directory node['kube_master']['config_path'] do
  recursive true
  action [:create]
end

file node['kube_master']['kubelet']['kubeconfig_path'] do
  content node['kube_master']['kubelet']['kubeconfig'].to_hash.to_yaml
  action :create
end

directory node['kube_master']['manifests_path'] do
  recursive true
  action [:create]
end

systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
end

# docker_image 'gcr.io/google_containers/hyperkube' do
#   tag 'v1.6.4'
#   action :pull
# end
#
# docker_container 'kubelet' do
#   repo 'gcr.io/google_containers/hyperkube'
#   tag 'v1.6.4'
#   network_mode 'host'
#   pid_mode 'host'
#   volume [
#     "#{node['kube_master']['kube_master']['ssl_path']}:#{node['kube_master']['kube_master']['ssl_path']}",
#     "#{node['kube_master']['kube_master']['manifests_path']}:#{node['kube_master']['kube_master']['manifests_path']}",
#     "/:/rootfs",
#     "/sys:/sys:ro",
#     "/dev:/dev",
#     "/var/lib/docker/:/var/lib/docker:rw",
#     "/var/lib/kubelet/:/var/lib/kubelet:rw",
#     "/var/run:/var/run:rw"
#   ]
#   command node['kube_master']['kube_master']['kubelet']['args'].join(' ')
#   restart_policy 'always'
# end

# docker_container 'apiserver' do
#   repo 'gcr.io/google_containers/hyperkube'
#   tag 'v1.6.4'
#   network_mode 'host'
#   volume "#{node['kube_master']['kube_master']['ssl_path']}:#{node['kube_master']['kube_master']['ssl_path']}"
#   command node['kube_master']['kube_master']['kube_apiserver']['args'].join(' ')
#   restart_policy 'always'
# end
#
# docker_container 'controller_manager' do
#   repo 'gcr.io/google_containers/hyperkube'
#   tag 'v1.6.4'
#   network_mode 'host'
#   volume "#{node['kube_master']['kube_master']['ssl_path']}:#{node['kube_master']['kube_master']['ssl_path']}"
#   command node['kube_master']['kube_master']['kube_controller_manager']['args'].join(' ')
#   restart_policy 'always'
# end
#
# docker_container 'proxy' do
#   repo 'gcr.io/google_containers/hyperkube'
#   tag 'v1.6.4'
#   network_mode 'host'
#   privileged true
#   command node['kube_master']['kube_master']['kube_proxy']['args'].join(' ')
#   restart_policy 'always'
# end
#
# docker_container 'controller-manager' do
#   repo 'gcr.io/google_containers/hyperkube'
#   tag 'v1.6.4'
#   network_mode 'host'
#   command node['kube_master']['kube_scheduler']['args'].join(' ')
#   restart_policy 'always'
# end
