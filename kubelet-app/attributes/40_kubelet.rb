node.default['kubernetes']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      node['kubernetes']['kubelet']['binary_path'],
      "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
      "--hostname-override=#{node['kubernetes']['node_ip']}",
      "--allow-privileged=true"
    ].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
