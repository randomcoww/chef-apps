##
## kubernetes
##

node.default['kubernetes']['version'] = '1.10.0'

# node.default['kubernetes']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kubernetes']['cluster_name'] = 'kube_cluster'
node.default['kubernetes']['cluster_domain'] = 'cluster.local'

node.default['kubernetes']['insecure_port'] = node['environment_v2']['port']['kube-master-insecure']
node.default['kubernetes']['secure_port'] = node['environment_v2']['port']['kube-master-internal']

## pod network
node.default['kubernetes']['cluster_cidr'] = '10.244.0.0/16'

## service network
node.default['kubernetes']['service_ip_range'] = '10.3.0.0/24'
node.default['kubernetes']['cluster_service_ip'] = '10.3.0.1'
node.default['kubernetes']['cluster_dns_ip'] = '10.3.0.10'


node.default['kubernetes']['flanneld_conf_path'] = "/etc/kube-flannel/net-conf.json"
node.default['kubernetes']['flanneld_conf'] = {
  "Network" => node['kubernetes']['cluster_cidr'],
  "Backend" => {
    "Type" => "vxlan"
  }
}

node.default['kubernetes']['cni_conf_path'] = "/etc/kubernetes/cni/net.d/10-flannel.conf"
node.default['kubernetes']['cni_conf'] = {
  "name": "cbr0",
  "type": "flannel",
  "delegate": {
    "hairpinMode": true,
    "isDefaultGateway": true
  }
}


## ssl paths
node.default['kubernetes']['apiserver_ssl_path'] = '/internalcerts/apiserver'
node.default['kubernetes']['etcd_ssl_path'] = '/internalcerts/etcd'
# node.default['kubernetes']['serviceaccount_ssl_path'] = '/internalcerts/serviceaccount'

node.default['kubernetes']['apiserver_ssl_base_path'] = ::File.join(node['kubernetes']['apiserver_ssl_path'], 'apiserver')
node.default['kubernetes']['apiserver_ssl_host_path'] = '/data/certs/apiserver'

node.default['kubernetes']['internal_ssl_base_path'] = "/etc/ssl/certs/internal"
node.default['kubernetes']['etcd_ssl_base_path'] = node['kubernetes']['internal_ssl_base_path']
node.default['kubernetes']['etcdpeer_ssl_base_path'] = node['kubernetes']['internal_ssl_base_path']

node.default['kubernetes']['service_account_key_path'] = "#{node['kubernetes']['apiserver_ssl_base_path']}-serviceaccount.pem"
## need something permanent for this
# node.default['kubernetes']['serviceaccount_ssl_base_path'] = ::File.join(node['kubernetes']['serviceaccount_ssl_path'], 'serviceaccount')
# node.default['kubernetes']['serviceaccount_ssl_host_path'] = '/data/certs/serviceaccount'

## etcd
node.default['kubernetes']['etcd_cluster_name'] = 'etcd-default'

## pods
# node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'
node.default['kubernetes']['manifests_path'] = '/config/manifests'
# node.default['kubernetes']['addons_path'] = '/etc/kubernetes/addons'

node.default['kubernetes']['manifests_extra_path'] = '/config/manifests_extra'

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

node.default['kubernetes']['client']['kubeconfig_path'] = '/var/lib/kubelet/client_kubeconfig'
node.default['kubernetes']['kubectl']['kubeconfig_path'] = '/var/lib/kubectl/kubeconfig'

node.default['environment_v2']['url']['manifests'] = 'https://raw.githubusercontent.com/randomcoww/environment-config/master/manifests'


##
## images
##
node.default['kube']['images']['hyperkube'] = "gcr.io/google_containers/hyperkube:v#{node['kubernetes']['version']}"
node.default['kube']['images']['mysql_cluster'] = "randomcoww/mysql_cluster:7.6.4"
node.default['kube']['images']['kea_dhcp4'] = "randomcoww/kea:1.3.0"
node.default['kube']['images']['haproxy'] = "randomcoww/haproxy:1.8.7"
node.default['kube']['images']['keepalived'] = "randomcoww/keepalived:20171201.08"
node.default['kube']['images']['unbound'] = "randomcoww/unbound:20171226.02"
node.default['kube']['images']['nftables'] = "randomcoww/nftables:20180305.01"
node.default['kube']['images']['kea_resolver'] = "randomcoww/go-kea-lease-resolver:20180111.01"
node.default['kube']['images']['kube_haproxy'] = "randomcoww/go-kube-haproxy:20180111.01"
node.default['kube']['images']['flannel'] = "quay.io/coreos/flannel:v0.10.0-amd64"
node.default['kube']['images']['dnsdist'] = "randomcoww/dnsdist:1.2.1"
node.default['kube']['images']['matchbox'] = "quay.io/coreos/matchbox:latest"
node.default['kube']['images']['tftpd_ipxe'] = "randomcoww/tftpd_ipxe:20180222.02"
node.default['kube']['images']['etcd'] = "quay.io/coreos/etcd:v3.3"
# node.default['kube']['images']['cfssl'] = "randomcoww/cfssl:1.3.1"
# node.default['kube']['images']['envwriter'] = "randomcoww/envwriter:20171220.02"
node.default['kube']['images']['vault'] = "vault:latest"
node.default['kube']['images']['vault_reader'] = "randomcoww/vault_reader:20180326.04"

# node.default['kube']['images']['libvirt_monitor'] = "randomcoww/go-libvirt-mon:20180306.01"
# node.default['kube']['images']['openvpn'] = "randomcoww/openvpn:20171216.01"
# node.default['kube']['images']['ddclient'] = "randomcoww/ddclient:20171201.02"
# node.default['kube']['images']['sshd'] = "randomcoww/sshd:20171201.01"
# node.default['kube']['images']['transmission'] = "randomcoww/transmission:20171201.01"
# node.default['kube']['images']['mpd'] = "randomcoww/mpd:20171201.01"
# node.default['kube']['images']['unifi'] = "randomcoww/unifi:20171217.05"
