##
## kubernetes
##

node.default['kubernetes']['version'] = '1.10.3'
node.default['kubernetes']['cluster_name'] = 'kube_cluster'
node.default['kubernetes']['cluster_domain'] = 'cluster.local'

## pod network
node.default['kubernetes']['cluster_cidr'] = '10.200.0.0/16'

## service network
node.default['kubernetes']['service_ip_range'] = '10.32.0.0/24'
node.default['kubernetes']['cluster_service_ip'] = '10.32.0.1'
node.default['kubernetes']['cluster_dns_ip'] = '10.32.0.10'

## etcd
node.default['kubernetes']['etcd_cluster_name'] = 'etcd-default'

## config
node.default['kubernetes']['kubernetes_path'] = "/var/lib/kubernetes"
node.default['kubernetes']['manifests_path'] = '/etc/kubernetes/manifests'

node.default['kubernetes']['kubectl']['remote_file'] = "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/kubectl"
node.default['kubernetes']['kubectl']['binary_path'] = "/usr/local/bin/kubectl"

##
## images
##
# node.default['kube']['images']['hyperkube'] = "gcr.io/google_containers/hyperkube:v#{node['kubernetes']['version']}"
node.default['kube']['images']['kube-apiserver'] = "gcr.io/google_containers/kube-apiserver:v#{node['kubernetes']['version']}"
node.default['kube']['images']['kube-scheduler'] = "gcr.io/google_containers/kube-scheduler:v#{node['kubernetes']['version']}"
node.default['kube']['images']['kube-controller-manager'] = "gcr.io/google_containers/kube-controller-manager:v#{node['kubernetes']['version']}"
node.default['kube']['images']['kube-proxy'] = "gcr.io/google_containers/kube-proxy:v#{node['kubernetes']['version']}"

node.default['kube']['images']['kea_dhcp4'] = "randomcoww/kea:1.4.0-beta"
# node.default['kube']['images']['haproxy'] = "haproxy:1.8-alpine"
node.default['kube']['images']['keepalived'] = "randomcoww/keepalived:20180412.02"
# node.default['kube']['images']['unbound'] = "randomcoww/unbound:20180412.01"
node.default['kube']['images']['nftables'] = "randomcoww/nftables:20180412.01"
node.default['kube']['images']['flannel'] = "quay.io/coreos/flannel:v0.10.0-amd64"
# node.default['kube']['images']['dnsdist'] = "randomcoww/dnsdist:1.3.0"
node.default['kube']['images']['matchbox'] = "quay.io/coreos/matchbox:latest"
node.default['kube']['images']['tftpd_ipxe'] = "randomcoww/tftpd_ipxe:20180222.02"
node.default['kube']['images']['etcd'] = "quay.io/coreos/etcd:v3.3"
