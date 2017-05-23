docker_image 'gcr.io/google_containers/hyperkube' do
  tag 'v1.6.4'
  action :pull
end

docker_container 'proxy' do
  repo 'gcr.io/google_containers/hyperkube'
  tag 'v1.6.4'
  network_mode 'host'
  privileged true
  command node['kubernetes']['kube_proxy']['args'].join(' ')
  restart_policy 'always'
end
