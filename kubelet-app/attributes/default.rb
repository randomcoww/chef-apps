node.default['kubernetes']['version'] = '1.7.0'

node.default['kubernetes']['insecure_port'] = 8080
node.default['kubernetes']['secure_port'] = 443

node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'

## kubernetes download
node.default['kubernetes']['kubelet']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubelet"
node.default['kubernetes']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"

node.default['kubernetes']['kube_proxy']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-proxy"
node.default['kubernetes']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"

node.default['kubernetes']['kubectl']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubectl"
node.default['kubernetes']['kubectl']['binary_path'] = "/usr/local/bin/kubectl"

node.default['kubelet']['static_pods'] ||= {}
