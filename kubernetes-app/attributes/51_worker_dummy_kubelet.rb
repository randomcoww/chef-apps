node.default['kube_worker_dummy']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => (node['kube_worker']['kubelet']['command'] + [
      "--register-schedulable=false"
    ]).join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
