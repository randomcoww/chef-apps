node.default['kubernetes']['version'] = '1.7.0'

node.default['kubernetes']['cluster_name'] = 'kube_cluster'
node.default['kubernetes']['cluster_domain'] = 'cluster.local'

node.default['kubernetes']['insecure_port'] = 8080
node.default['kubernetes']['secure_port'] = 443

## pod network
node.default['kubernetes']['cluster_cidr'] = '10.2.0.0/16'

## service network
node.default['kubernetes']['service_ip_range'] = '10.3.0.0/24'
node.default['kubernetes']['cluster_service_ip'] = '10.3.0.1'
node.default['kubernetes']['cluster_dns_ip'] = '10.3.0.10'

## pods
node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'
node.default['kubernetes']['addons_path'] = '/etc/kubernetes/addons'
node.default['kubernetes']['hyperkube_image'] = "gcr.io/google_containers/hyperkube:v#{node['kubernetes']['version']}"

## kubernetes download
node.default['kubernetes']['kubelet']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubelet"
node.default['kubernetes']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"

node.default['kubernetes']['kube_proxy']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-proxy"
node.default['kubernetes']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"


node.default['kubelet']['static_pods'] ||= {}
