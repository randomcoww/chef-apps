## worker
node.default['kube_client']['kubectl']['kubeconfig_path'] = '/etc/kubectl/kubeconfig'
node.default['kube_client']['kubectl']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        "server" => "https://#{node['kubernetes']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kubectl",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubectl-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kubectl"
      }
    }
  ],
  "current-context" => "kubectl-context"
}
