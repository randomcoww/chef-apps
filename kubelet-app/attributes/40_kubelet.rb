node.default['kubernetes']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      node['kubernetes']['kubelet']['binary_path'],
      "--api-servers=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
      "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
      "--cluster-dns=#{node['kubernetes']['cluster_dns_ip']}",
      "--cluster-domain=#{node['kubernetes']['cluster_domain']}",
      "--register-schedulable=false",
      "--allow-privileged=true"
      # "--resolv-conf=''"
    ].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
