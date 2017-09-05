etcd_initial_cluster = node['kube_manifests']['etcd_flannel']['hosts'].map { |host|
  "#{host}=http://#{node['environment_v2']['host'][host]['ip_lan']}:2380"
}

node['kube_manifests']['etcd_flannel']['hosts'].each do |host|

  ip = node['environment_v2']['host'][host]['ip_lan']
  environment = {
    "ETCD_NAME" => host,
    "ETCD_LISTEN_PEER_URLS" => "http://#{ip}:2380",
    "ETCD_LISTEN_CLIENT_URLS" => [ip, '127.0.0.1'].map { |e|
        "http://#{e}:2379"
      }.join(','),
    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "http://#{ip}:2380",
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    # "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_STATE" => "existing",
    "ETCD_INITIAL_CLUSTER_TOKEN" => "etcd-cluster-1",
    "ETCD_ADVERTISE_CLIENT_URLS" => "http://#{ip}:2379"
  }

  etcd_flannel_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "namespace" => "kube-system",
      "name" => "etcd"
    },
    "spec" => {
      "hostNetwork" => true,
      "restartPolicy" => 'Always',
      "containers" => [
        {
          "name" => "kube-etcd",
          "image" => "quay.io/coreos/etcd:latest",
          "command" => [
            "/usr/local/bin/etcd",
            "--data-dir=/var/lib/etcd"
          ],
          "env" => environment.map { |k, v|
            {
              "name" => k,
              "value" => v
            }
          },
          "volumeMounts" => [
            {
              "mountPath" => "/var/lib/etcd",
              "name" => "etcd-data"
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "etcd-data",
          "emptyDir" => {}
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd-flannel.yaml'] = etcd_flannel_manifest
end
