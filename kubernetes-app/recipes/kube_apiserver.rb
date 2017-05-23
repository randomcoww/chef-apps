docker_image 'gcr.io/google_containers/hyperkube' do
  tag 'v1.6.4'
  action :pull
end

docker_container 'apiserver' do
  repo 'gcr.io/google_containers/hyperkube'
  tag 'v1.6.4'
  network_mode 'host'
  volume "#{node['kubernetes']['kube_master']['base_path']}:#{node['kubernetes']['kube_master']['base_path']}"
  command node['kubernetes']['kube_apiserver']['args'].join(' ')
  restart_policy 'always'
end
