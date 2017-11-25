[
  node['kubernetes']['ssl_path'],
  ::File.dirname(node['kubernetes']['kubectl']['kubeconfig_path'])
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


[
  'kubectl',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0755'
    action :create_if_missing
  end
end


cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)
ca = cert_generator.root_ca

##
## kube ssl
##
key = cert_generator.generate_key
cert = cert_generator.node_cert(
  [
    ['CN', "kubectl"]
  ],
  key,
  {
    "basicConstraints" => "CA:FALSE",
    "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
  },
  {}
)


file node['kubernetes']['ca_path'] do
  content ca.to_pem
end

file node['kubernetes']['key_path'] do
  content key.to_pem
end

file node['kubernetes']['cert_path'] do
  content cert.to_pem
end


server_alias = [
  node['environment_v2']['set']['kube-master']['alias'],
  node['environment_v2']['domain']['vip_lan'],
  node['environment_v2']['domain']['top']
].join('.')


kubelet_kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        # "server" => "https://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['haproxy']['kube-master']['port']}"
        "server" => "https://#{server_alias}:#{node['environment_v2']['haproxy']['kube-master']['port']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
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


file node['kubernetes']['kubectl']['kubeconfig_path'] do
  content kubelet_kube_config.to_yaml
  action :create
end
