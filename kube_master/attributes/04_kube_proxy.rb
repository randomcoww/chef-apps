node.default['kube_master']['kube_proxy']['remote_file'] = 'https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kube-proxy'
node.default['kube_master']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"

node.default['kube_master']['kube_proxy']['command'] = [
  node['kube_master']['kube_proxy']['binary_path'],
  "--cluster-cidr=#{node['kube_master']['cluster_cidr']}",
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
