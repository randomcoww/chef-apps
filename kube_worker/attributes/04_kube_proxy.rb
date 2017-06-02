node.default['kube_worker']['kube_proxy']['remote_file'] = 'https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kube-proxy'
node.default['kube_worker']['kube_proxy']['binary_path'] = "/usr/local/bin/kube-proxy"


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


node.default['kube_worker']['kube_proxy']['command'] = [
  node['kube_worker']['kube_proxy']['binary_path'],
  "--cluster-cidr=#{node['kube_worker']['cluster_cidr']}",
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
    "ExecStart" => node['kube_worker']['kube_proxy']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
