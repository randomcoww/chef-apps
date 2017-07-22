node.default['kubernetes']['kube_proxy']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Proxy'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      node['kubernetes']['kube_proxy']['binary_path'],
      "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
      "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
    ].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
