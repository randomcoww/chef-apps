node.default['kube_master']['kube_apiserver']['args'] = [
  "--bind-address=0.0.0.0",
  # "--bind-address=127.0.0.1",
  # "--address=127.0.0.1",
  "--secure-port=443",
  "--service-cluster-ip-range=#{node['kube_master']['service_ip_range']}",
  "--etcd-servers=#{node['kube_master']['etcd']['nodes']}",
  "--tls-cert-file=#{node['kube_master']['cert_path']}",
  "--tls-private-key-file=#{node['kube_master']['key_path']}",
  "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
  "--client-ca-file=#{node['kube_master']['ca_path']}",
  "--service-account-key-file=#{node['kube_master']['key_path']}",
  # "--token-auth-file=#{node['kube_master']['token_file_path']}",
  # "--allow-privileged=true"
]

node.default['kube_master']['kube_apiserver']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Apiserver'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kube-apiserver #{node['kube_master']['kube_apiserver']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
