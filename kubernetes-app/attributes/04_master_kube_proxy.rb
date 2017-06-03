## master
node.default['kube_master']['kube_proxy']['command'] = [
  node['kubernetes']['kube_proxy']['binary_path'],
  "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
  "--master=http://127.0.0.1:8080"
]

node.default['kube_master']['kube_proxy']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Proxy'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kube_proxy']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
