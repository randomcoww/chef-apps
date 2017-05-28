## kubeconfig
node.default['kube_master']['kube_proxy']['kubeconfig_path'] = '/var/lib/kube_proxy/kubeconfig'
node.default['kube_master']['kube_proxy']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kube_master']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kube_master']['ca_path'],
        "server" => "https://#{node['kube_master']['node_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube_proxy",
      "user" => {
        "client-certificate" => node['kube_master']['cert_path'],
        "client-key" => node['kube_master']['key_path'],
        "token" => node['kube_master']['tokens']['kube_proxy']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kube-proxy-context",
      "context" => {
        "cluster" => node['kube_master']['cluster_name'],
        "user" => "kube_proxy"
      }
    }
  ],
  "current-context" => "kube-proxy-context"
}


node.default['kube_master']['kube_proxy']['args'] = [
  "--master=https://#{node['kube_master']['node_ip']}",
  "--kubeconfig=#{node['kube_master']['kube_proxy']['kubeconfig_path']}",
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
