## worker
node.default['kube_worker']['kube_proxy']['kubeconfig_path'] = '/var/lib/kube_proxy/kubeconfig'
node.default['kube_worker']['kube_proxy']['kubeconfig'] = {
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


node.default['kube_worker']['kube_proxy']['command'] = [
  node['kubernetes']['kube_proxy']['binary_path'],
  "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
  "--master=https://#{node['kubernetes']['master_ip']}",
  "--kubeconfig=#{node['kubernetes']['kube_proxy']['kubeconfig_path']}",
]

node.default['kube_worker']['kube_proxy']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Proxy'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_worker']['kube_proxy']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
