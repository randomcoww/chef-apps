## master
node.override['kube_master']['kubelet']['command'] = [
  node['kubernetes']['kubelet']['binary_path'],
  "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
  "--allow-privileged=true"
  # "--resolv-conf=''"
]

node.override['kube_master']['kubelet']['systemd'] = {
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

node.default['kubelet']['static_pods'] ||= {}
