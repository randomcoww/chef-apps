node.default['kube_worker_dummy']['kubelet']['command'] = [
  node['kubernetes']['kubelet']['binary_path'],
  "--api-servers=https://#{node['kubernetes']['master_ip']}",
  "--container-runtime=docker",
  "--kubeconfig=#{node['kube_worker']['kubelet']['kubeconfig_path']}",
  "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
  "--cluster-dns=#{node['kubernetes']['cluster_dns_ip']}",
  "--cluster-domain=#{node['kubernetes']['cluster_domain']}",
  "--hostname-override=#{node['kubernetes']['node_ip']}",
  "--register-schedulable=false",
  "--allow-privileged=true"
]

node.default['kube_worker_dummy']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_worker_dummy']['kubelet']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
