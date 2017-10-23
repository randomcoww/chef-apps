domain = [
  node['environment_v2']['domain']['host_lan'],
  node['environment_v2']['domain']['top']
].join('.')

etcd_cluster_config = node['environment_v2']['set']['etcd']['hosts'].map { |e|
  "#{e}=http://#{[e, domain].join('.')}:2380"
}.join(',')

node['environment_v2']['set']['etcd']['hosts'].each do |host|

  hostname = [host, domain].join('.')

  etcd_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "namespace" => "kube-system",
      "name" => "etcd"
    },
    "spec" => {
      "hostNetwork" => true,
      "restartPolicy" => 'Always',
      "initContainers" => [
        {
          "name" => "etcd-restore",
          "image" => node['kube']['images']['etcd'],
          "command" => [
            "etcdctl",
            "snapshot",
            "restore",
            "/snapshot/etcd-recovery/snapshot.db",
            "--name",
            host,
            "--data-dir",
            "/var/lib/etcd/restore",
            "--initial-advertise-peer-urls",
            "http://#{hostname}:2380",
            "--initial-cluster",
            etcd_cluster_config,
            "--initial-cluster-token",
            "etcd-1"
          ],
          "env" => [
            {
              "name" => "ETCDCTL_API",
              "value" => "3"
            }
          ],
          "volumeMounts" => [
            {
              "mountPath" => "/snapshot",
              "name" => "etcd-snapshot"
            },
            {
              "mountPath" => "/var/lib/etcd",
              "name" => "etcd-data"
            }
          ]
        }
      ],
      "containers" => [
        {
          "name" => "etcd",
          "image" => node['kube']['images']['etcd'],
          "command" => [
            "etcd",
            "--name",
            host,
            "--data-dir",
            "/var/lib/etcd/restore",
            "--discovery-srv",
            domain,
            "--initial-advertise-peer-urls",
            "http://$(HOST_IP):2380",
            "--listen-peer-urls",
            "http://$(HOST_IP):2380",
            "--listen-client-urls",
            "http://$(HOST_IP):2379,http://127.0.0.1:2379",
            "--advertise-client-urls",
            "http://$(HOST_IP):2379",
            "--initial-cluster-state",
            "existing",
            "--initial-cluster-token",
            "etcd-1"
          ],
          "env" => [
            {
              "name" => "HOST_IP",
              "valueFrom" => {
                "fieldRef" => {
                  "fieldPath" => "status.hostIP"
                }
              }
            }
          ],
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
          "name" => "etcd-snapshot",
          "gitRepo" => {
            "repository" => "https://github.com/randomcoww/etcd-recovery.git",
            "revision" => "master"
          }
        },
        {
          "name" => "etcd-data",
          "emptyDir" => {}
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd.yaml'] = etcd_manifest
end
