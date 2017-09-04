cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)

node.default['qemu']['current_config']['kube_ca'] = cert_generator.root_ca.to_pem
key = cert_generator.generate_key

node.default['qemu']['current_config']['kube_worker_key'] = key.to_pem

cert = cert_generator.node_cert(
  [
    ['CN', "kube-#{node['qemu']['current_config']['hostname']}"]
  ],
  key,
  {
    "basicConstraints" => "CA:FALSE",
    "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
  },
  {
    'IP.1' => node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']
  }
)

node.default['qemu']['current_config']['kube_worker_cert'] = cert.to_pem
