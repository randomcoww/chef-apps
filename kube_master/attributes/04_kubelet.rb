node.default['kube_master']['kubelet']['args'] = [
  "--api-servers=http://127.0.0.1:8080",
  "--pod-manifest-path=#{node['kube_master']['manifests_path']}",
  "--cluster_dns=#{node['kube_master']['cluster_dns_ip']}",
  "--cluster_domain=cluster.local"
  # "--register-node=true",
]

node.default['kube_master']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kubelet #{node['kube_master']['kubelet']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
