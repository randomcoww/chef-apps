node.default['kube']['images']['mysql_cluster_mysqld'] = "randomcoww/k8s-mysql_cluster_mysqld:latest"
node.default['kube']['images']['mysql_cluster_ndbd'] = "randomcoww/k8s-mysql_cluster_ndbd:latest"
node.default['kube']['images']['mysql_cluster_ndb_mgmd'] = "randomcoww/k8s-mysql_cluster_ndb_mgmd:latest"
node.default['kube']['images']['mysql_cluster_seeder'] = "randomcoww/k8s-mysql_cluster_seeder:latest"
node.default['kube']['images']['kea_dhcp4'] = "randomcoww/k8s-kea:latest"
node.default['kube']['images']['kea_dhcp_ddns'] = "randomcoww/k8s-kea:latest"
node.default['kube']['images']['haproxy'] = "randomcoww/k8s-haproxy:latest"
node.default['kube']['images']['keepalived'] = "randomcoww/k8s-keepalived:latest"
node.default['kube']['images']['ddclient'] = "randomcoww/k8s-ddclient:latest"
node.default['kube']['images']['knot'] = "randomcoww/k8s-knot:latest"
node.default['kube']['images']['nsd'] = "randomcoww/k8s-nsd:latest"
node.default['kube']['images']['unbound'] = "randomcoww/k8s-unbound:latest"
node.default['kube']['images']['openvpn'] = "randomcoww/k8s-openvpn:latest"
node.default['kube']['images']['sshd'] = "randomcoww/k8s-sshd:latest"
node.default['kube']['images']['env_writer'] = "randomcoww/env_writer:latest"
node.default['kube']['images']['etcd'] = "quay.io/coreos/etcd:latest"
node.default['kube']['images']['nftables'] = "randomcoww/k8s-nftables:latest"
node.default['kube']['images']['kea_resolver'] = "randomcoww/go-kea-lease-resolver:latest"
# node.default['kube']['images']['kube_dashboard'] = "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1"


##
## kubernetes
##

node.default['kubernetes']['version'] = '1.7.6'

# node.default['kubernetes']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kubernetes']['cluster_name'] = 'kube_cluster'
node.default['kubernetes']['cluster_domain'] = 'cluster.local'

# node.default['kubernetes']['master_hosts'] = node['environment_v2']['set']['kube-master']['hosts']
# node.default['kubernetes']['etcd_hosts'] = node['environment_v2']['set']['etcd']['hosts']

node.default['kubernetes']['insecure_port'] = 8080
node.default['kubernetes']['secure_port'] = 443

## pod network
node.default['kubernetes']['cluster_cidr'] = '10.244.0.0/16'

## service network
node.default['kubernetes']['service_ip_range'] = '10.3.0.0/24'
node.default['kubernetes']['cluster_service_ip'] = '10.3.0.1'
node.default['kubernetes']['cluster_dns_ip'] = '10.3.0.10'

node.default['kubernetes']['flanneld_network'] = {
  "Network" => node['kubernetes']['cluster_cidr'],
  "Backend" => {
    "Type" => "vxlan"
  }
}

node.default['kubernetes']['srv_path'] = '/srv/kubernetes'
## cert and auth
node.default['kubernetes']['ca_path'] = ::File.join(node['kubernetes']['srv_path'], 'ca.crt')
node.default['kubernetes']['cert_path'] = ::File.join(node['kubernetes']['srv_path'], 'server.crt')
node.default['kubernetes']['key_path'] = ::File.join(node['kubernetes']['srv_path'], 'server.key')


## pods
# node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'
node.default['kubernetes']['manifests_path'] = '/config/manifests'
# node.default['kubernetes']['addons_path'] = '/etc/kubernetes/addons'


## kubernetes download
# node.default['kubernetes']['kubelet']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubelet"
# node.default['kubernetes']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"
#
# node.default['kubernetes']['kube_proxy']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kube-proxy"
# node.default['kubernetes']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"

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


node.default['kube']['images']['hyperkube'] = "gcr.io/google_containers/hyperkube:v#{node['kubernetes']['version']}"


node.default['kubernetes']['kubelet']['kubeconfig_path'] = '/var/lib/kubelet/kubeconfig'
node.default['kubernetes']['kube_proxy']['kubeconfig_path'] = '/var/lib/kube_proxy/kubeconfig'
node.default['kubernetes']['kubectl']['kubeconfig_path'] = '/var/lib/kubectl/kubeconfig'


node.default['kube_manifests']['dns']['hosts'] = node['environment_v2']['set']['dns']['hosts']
node.default['kube_manifests']['gateway']['hosts'] = node['environment_v2']['set']['gateway']['hosts'] +
  node['environment_v2']['set']['haproxy']['hosts']

node.default['kube_manifests']['kea']['hosts'] = node['environment_v2']['set']['kea']['hosts']
node.default['kube_manifests']['kube_master']['hosts'] = node['environment_v2']['set']['kube-master']['hosts']
node.default['kube_manifests']['kube_worker']['hosts'] = node['environment_v2']['set']['kube-worker']['hosts']
