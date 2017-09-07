cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)

current_host = node['qemu']['current_config']['hostname']

node.default['qemu']['current_config']['kube_ca'] = cert_generator.root_ca.to_pem
key = cert_generator.generate_key

node.default['qemu']['current_config']['kube_master_key'] = key.to_pem

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
    'DNS.1' => 'kubernetes',
    'DNS.2' => 'kubernetes.default',
    'DNS.3' => 'kubernetes.default.svc',
    'DNS.4' => "kubernetes.default.svc.#{node['kubernetes']['cluster_domain']}",
    'IP.1' => node['kubernetes']['cluster_service_ip'],
    'IP.2' => node['environment_v2']['host'][current_host]['ip_lan'],
    'IP.3' => node['environment_v2']['set']['gateway']['vip_lan']
  }
)

node.default['qemu']['current_config']['kube_master_cert'] = cert.to_pem
