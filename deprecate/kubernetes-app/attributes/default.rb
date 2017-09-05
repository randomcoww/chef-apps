node.default['kubernetes']['version'] = '1.7.0'

node.default['kubernetes']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kubernetes']['cluster_name'] = 'kube_cluster'
node.default['kubernetes']['cluster_domain'] = 'cluster.local'
node.default['kubernetes']['master_ip'] = node['environment_v2']['set']['haproxy']['vip_lan']

node.default['kubernetes']['insecure_port'] = 8080
node.default['kubernetes']['secure_port'] = 443

## pod network
node.default['kubernetes']['cluster_cidr'] = '10.244.0.0/16'

## service network
node.default['kubernetes']['service_ip_range'] = '10.3.0.0/24'
node.default['kubernetes']['cluster_service_ip'] = '10.3.0.1'
node.default['kubernetes']['cluster_dns_ip'] = '10.3.0.10'


node.default['kubernetes']['srv_path'] = '/srv/kubernetes'
## cert and auth
node.default['kubernetes']['ca_path'] = ::File.join(node['kubernetes']['srv_path'], 'ca.crt')
node.default['kubernetes']['cert_path'] = ::File.join(node['kubernetes']['srv_path'], 'server.crt')
node.default['kubernetes']['key_path'] = ::File.join(node['kubernetes']['srv_path'], 'server.key')


## pods
node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'
# node.default['kubernetes']['addons_path'] = '/etc/kubernetes/addons'
node.default['kubernetes']['hyperkube_image'] = "gcr.io/google_containers/hyperkube:v#{node['kubernetes']['version']}"


## kubernetes download
node.default['kubernetes']['kubelet']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubelet"
node.default['kubernetes']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"

node.default['kubernetes']['kube_proxy']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-proxy"
node.default['kubernetes']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"

# node.default['kubernetes']['kube_apiserver']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-apiserver"
# node.default['kubernetes']['kube_apiserver']['binary_path'] = "/usr/local/bin/kube-apiserver"
#
# node.default['kubernetes']['kube_controller_manager']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-controller-manager"
# node.default['kubernetes']['kube_controller_manager']['binary_path'] = "/usr/local/bin/kube-controller-manager"
#
# node.default['kubernetes']['kube_scheduler']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-scheduler"
# node.default['kubernetes']['kube_scheduler']['binary_path'] = "/usr/local/bin/kube-scheduler"

node.default['kubernetes']['kubectl']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubectl"
node.default['kubernetes']['kubectl']['binary_path'] = "/usr/local/bin/kubectl"
