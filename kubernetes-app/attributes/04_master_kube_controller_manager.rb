## master
node.default['kube_master']['kube_controller_manager']['command'] = [
  node['kubernetes']['kube_controller_manager']['binary_path'],
  "--cluster-name=#{node['kubernetes']['cluster_name']}",
  "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
  "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
  "--service-account-private-key-file=#{node['kubernetes']['key_path']}",
  "--root-ca-file=#{node['kubernetes']['ca_path']}",
  "--leader-elect=true",
  "--master=http://127.0.0.1:8080",
]

node.default['kube_master']['kube_controller_manager']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Apiserver'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kube_controller_manager']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
