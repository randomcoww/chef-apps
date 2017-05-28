node.default['kube_master']['kube_proxy']['args'] = [
  "--cluster-cidr=#{node['kube_master']['service_ip_range']}",
  "--master=http://127.0.0.1:8080"
]

node.default['kube_master']['kube_proxy']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Proxy'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kube-proxy #{node['kube_master']['kube_proxy']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
