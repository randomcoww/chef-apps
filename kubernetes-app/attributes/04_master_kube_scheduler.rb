## master
node.default['kube_master']['kube_scheduler']['command'] = [
  node['kubernetes']['kube_scheduler']['binary_path'],
  "--master=http://127.0.0.1:8080",
  "--leader-elect=true"
]

node.default['kube_master']['kube_scheduler']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Apiserver'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kube_scheduler']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
