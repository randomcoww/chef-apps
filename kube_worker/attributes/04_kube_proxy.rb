## kubeconfig
node.default['kube_worker']['kube_proxy']['kubeconfig_path'] = '/var/lib/kube_proxy/kubeconfig'
node.default['kube_worker']['kube_proxy']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kube_worker']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kube_worker']['ca_path'],
        "server" => "https://#{node['kube_worker']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube_proxy",
      "user" => {
        "client-certificate" => node['kube_worker']['cert_path'],
        "client-key" => node['kube_worker']['key_path'],
        # "token" => node['kube_worker']['tokens']['kube_proxy']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kube-proxy-context",
      "context" => {
        "cluster" => node['kube_worker']['cluster_name'],
        "user" => "kube_proxy"
      }
    }
  ],
  "current-context" => "kube-proxy-context"
}


node.default['kube_worker']['kube_proxy']['args'] = [
  "--cluster-cidr=#{node['kube_worker']['cluster_cider']}",
  "--master=https://#{node['kube_worker']['master_ip']}",
  "--kubeconfig=#{node['kube_worker']['kube_proxy']['kubeconfig_path']}",
]

node.default['kube_worker']['kube_proxy']['systemd'] = {
  'Unit' => {
    'Description' => 'Kube Proxy'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kube-proxy #{node['kube_worker']['kube_proxy']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
