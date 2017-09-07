cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)

current_host = node['qemu']['current_config']['hostname']

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
    'IP.1' => node['environment_v2']['host'][current_host]['ip_lan']
  }
)

node.default['qemu']['current_config']['kube_worker_cert'] = cert.to_pem


node.default['kube_worker']['kubelet']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        # "server" => "https://#{node['kubernetes']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubelet-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kubelet"
      }
    }
  ],
  "current-context" => "kubelet-context"
}


node.default['kube_worker']['kube_proxy']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        # "server" => "https://#{node['kubernetes']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube_proxy",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kube_proxy']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kube-proxy-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kube_proxy"
      }
    }
  ],
  "current-context" => "kube-proxy-context"
}
