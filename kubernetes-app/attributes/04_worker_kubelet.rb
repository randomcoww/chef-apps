## worker
node.default['kube_worker']['kubelet']['kubeconfig_path'] = '/var/lib/kubelet/kubeconfig'
node.default['kube_worker']['kubelet']['kubeconfig'] = {
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


node.default['kube_worker']['kubelet']['command'] = [
  node['kubernetes']['kubelet']['binary_path'],
  "--api-servers=https://#{node['kubernetes']['master_ip']}",
  "--container-runtime=docker",
  "--kubeconfig=#{node['kube_worker']['kubelet']['kubeconfig_path']}",
  "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
  "--cluster-dns=#{node['kubernetes']['cluster_dns_ip']}",
  "--cluster-domain=#{node['kubernetes']['cluster_domain']}",
  "--hostname-override=#{node['kubernetes']['node_ip']}",
  # "--resolv-conf=''"
  # "--register-node=true",
]

node.default['kube_worker']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_worker']['kubelet']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
