node.default['kube_master']['kubelet']['remote_file'] = 'https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubelet'
node.default['kube_master']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"

node.default['kube_master']['kubelet']['command'] = [
  node['kube_master']['kubelet']['binary_path'],
  "--api-servers=http://127.0.0.1:8080",
  "--pod-manifest-path=#{node['kube_master']['manifests_path']}",
  "--cluster-dns=#{node['kube_master']['cluster_dns_ip']}",
  "--cluster-domain=#{node['kube_master']['cluster_domain']}",
  "--register-schedulable=false",
  "--hostname-override=#{node['kube_master']['node_ip']}",
  # "--resolv-conf=''"
]

node.default['kube_master']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kubelet']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
