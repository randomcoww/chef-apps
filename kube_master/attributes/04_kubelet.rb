node.default['kube_master']['kubelet']['kubeconfig_path'] = ::File.join(node['kube_master']['config_path'], 'master-kubeconfig.yaml')
node.default['kube_master']['kubelet']['kubeconfig'] = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => {
    "name" => "local",
    "cluster" => {
      "certificate-authority" => node['kube_master']['ca_path']
    }
  },
  "users" => {
    "name" => "kubelet",
    "user" => {
      "client-certificate" => node['kube_master']['cert_path'],
      "client-key" => node['kube_master']['key_path']
    }
  },
  "contexts" => {
    "context" => {
      "cluster" => "local",
      "user" => "kubelet"
    },
    "name" => "kubelet-context"
  },
  "current-context" => "kubelet-context"
}

## kubelet
node.default['kube_master']['kubelet']['kubelet']['args'] = [
  "--allow-privileged=true",
  "--pod-manifest-path=#{node['kube_master']['manifests_path']}",
  "--api-servers=http://127.0.0.1:8080",
  "--kubeconfig=#{node['kube_master']['kubelet']['kubeconfig_path']}",
  "--cluster_dns=#{node['kube_master']['cluster_dns_ip']}",
  "--cluster_domain=cluster.local"
]

node.default['kube_master']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => "/usr/local/bin/kubelet #{node['kube_master']['kubelet']['kubelet']['args'].join(' ')}"
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
