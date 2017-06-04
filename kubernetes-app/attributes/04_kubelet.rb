


## master
node.default['kube_master']['kubelet']['command'] = [
  node['kubernetes']['kubelet']['binary_path'],
  "--api-servers=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
  "--pod-manifest-path=#{node['kube_master']['manifests_path']}",
  "--cluster-dns=#{node['kube_master']['cluster_dns_ip']}",
  "--cluster-domain=#{node['kube_master']['cluster_domain']}",
  "--register-schedulable=false",
  "--hostname-override=#{node['kube_master']['node_ip']}",
  # "--resolv-conf=''"
]

node.default['kube_master']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => node['kube_master']['kubelet']['command'].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}


## worker
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
  node['kubernetes']['kubelet']['binary_path'],
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
