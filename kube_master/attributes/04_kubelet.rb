## kubeconfig
node.default['kube_master']['kubelet']['kubeconfig_path'] = '/var/lib/kubelet/kubeconfig'
node.default['kube_master']['kubelet']['kubeconfig'] = {
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
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kube_master']['cert_path'],
        "client-key" => node['kube_master']['key_path'],
        "token" => node['kube_master']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubelet-context",
      "context" => {
        "cluster" => node['kube_master']['cluster_name'],
        "user" => "kubelet"
      }
    }
  ],
  "current-context" => "kubelet-context"
}


node.default['kube_master']['kubelet']['args'] = [
  "--api-servers=http://127.0.0.1:8080",
  "--container-runtime=docker",
  "--kubeconfig=#{node['kube_master']['kubelet']['kubeconfig_path']}",
  "--pod-manifest-path=#{node['kube_master']['manifests_path']}",
  "--cluster_dns=#{node['kube_master']['cluster_dns_ip']}",
  "--cluster_domain=cluster.local"
  # "--register-node=true",
]

node.default['kube_master']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kubelet #{node['kube_master']['kubelet']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
