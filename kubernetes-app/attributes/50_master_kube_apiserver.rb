## master
node.default['kube_master']['kube_apiserver']['command'] = [
  node['kubernetes']['kube_apiserver']['binary_path'],
  "--bind-address=0.0.0.0",
  # "--bind-address=127.0.0.1",
  # "--address=127.0.0.1",
  "--secure-port=#{node['kubernetes']['secure_port']}",
  "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
  "--etcd-servers=#{node['kubernetes']['etcd']['nodes']}",
  "--tls-cert-file=#{node['kubernetes']['cert_path']}",
  "--tls-private-key-file=#{node['kubernetes']['key_path']}",
  "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
  "--client-ca-file=#{node['kubernetes']['ca_path']}",
  "--service-account-key-file=#{node['kubernetes']['key_path']}",
  # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
  # "--allow-privileged=true"
]

node.default['kube_master']['kube_apiserver']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Apiserver'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kube_apiserver']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
