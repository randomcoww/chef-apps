## master
node.default['kube_standalone']['kubelet']['command'] = [
  node['kubernetes']['kubelet']['binary_path'],
  "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
  "--allow-privileged=true"
]

node.default['kube_standalone']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_standalone']['kubelet']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
