node.default['kube_worker']['kubelet']['remote_file'] = 'https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubelet'
node.default['kube_worker']['kubelet']['binary_path'] = "/usr/local/bin/kubelet"


## kubeconfig
node.default['kube_worker']['kubelet']['kubeconfig_path'] = '/var/lib/kubelet/kubeconfig'
node.default['kube_worker']['kubelet']['kubeconfig'] = {
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
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kube_worker']['cert_path'],
        "client-key" => node['kube_worker']['key_path'],
        # "token" => node['kube_worker']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubelet-context",
      "context" => {
        "cluster" => node['kube_worker']['cluster_name'],
        "user" => "kubelet"
      }
    }
  ],
  "current-context" => "kubelet-context"
}


node.default['kube_worker']['kubelet']['command'] = [
  node['kube_worker']['kubelet']['binary_path'],
  "--api-servers=https://#{node['kube_worker']['master_ip']}",
  "--container-runtime=docker",
  "--kubeconfig=#{node['kube_worker']['kubelet']['kubeconfig_path']}",
  "--pod-manifest-path=#{node['kube_worker']['manifests_path']}",
  "--cluster-dns=#{node['kube_worker']['cluster_dns_ip']}",
  "--cluster-domain=#{node['kube_worker']['cluster_domain']}",
  "--hostname-override=#{node['kube_worker']['node_ip']}",
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
