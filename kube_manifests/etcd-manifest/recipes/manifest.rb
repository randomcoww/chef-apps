## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")

ssl_config = {
  "auth_keys" => {
    "key1" => {
      "type" => "standard",
      "key" => "245f62575040243f3d544926562f4a5d"
    }
  },
  "signing" => {
    "default" => {
      "auth_remote" => {
        "remote" => "cfssl_server",
        "auth_key" => "key1"
      }
    }
  },
  "remotes" => {
    "cfssl_server" => node['environment_v2']['set']['ca']['hosts'].map { |e|
      "http://#{node['environment_v2']['host'][e]['ip']['store']}:8888"
    }.join(',')
  }
}.to_json


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  #
  # etcd ssl
  #
  ssl_csr = {
    "CN" => host,
    "hosts" => [
      ip
    ],
    "key" => {
      "algo" => "ecdsa",
      "size" => 256
    }
  }.to_json

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => "/var/lib/etcd",

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['kubernetes']['etcd_cluster_name'],

    "ETCD_TRUSTED_CA_FILE" => "#{node['kubernetes']['etcd_ssl_base_path']}-ca.pem",
    "ETCD_CERT_FILE" => "#{node['kubernetes']['etcd_ssl_base_path']}.pem",
    "ETCD_KEY_FILE" => "#{node['kubernetes']['etcd_ssl_base_path']}-key.pem",

    "ETCD_PEER_TRUSTED_CA_FILE" => "#{node['kubernetes']['etcdpeer_ssl_base_path']}-ca.pem",
    "ETCD_PEER_CERT_FILE" => "#{node['kubernetes']['etcdpeer_ssl_base_path']}.pem",
    "ETCD_PEER_KEY_FILE" => "#{node['kubernetes']['etcdpeer_ssl_base_path']}-key.pem",

    "ETCD_PEER_CLIENT_CERT_AUTH" => "true"
  }

  etcd_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "name" => "kube-etcd",
      "namespace" => "kube-system",
    },
    "spec" => {
      "hostNetwork" => true,
      "initContainers" => [
        {
          "name" => "cfssl-etcd",
          "image" => node['kube']['images']['cfssl'],
          "command" => [
            "/gencert_wrapper.sh"
          ],
          "args" => [
            "-p",
            "server",
            "-o",
            node['kubernetes']['etcd_ssl_base_path']
          ],
          "env" => [
            {
              "name" => "CSR",
              "value" => ssl_csr
            },
            {
              "name" => "CONFIG",
              "value" => ssl_config
            }
          ],
          "volumeMounts" => [
            {
              "name" => "etcd-certs",
              "mountPath" => node['kubernetes']['etcd_ssl_path'],
              "readOnly" => false
            }
          ]
        },
        {
          "name" => "cfssl-etcd-peer",
          "image" => node['kube']['images']['cfssl'],
          "command" => [
            "/gencert_wrapper.sh"
          ],
          "args" => [
            "-p",
            "peer",
            "-o",
            node['kubernetes']['etcdpeer_ssl_base_path']
          ],
          "env" => [
            {
              "name" => "CSR",
              "value" => ssl_csr
            },
            {
              "name" => "CONFIG",
              "value" => ssl_config
            }
          ],
          "volumeMounts" => [
            {
              "name" => "etcd-certs",
              "mountPath" => node['kubernetes']['etcd_ssl_path'],
              "readOnly" => false
            }
          ]
        }
      ],
      "containers" => [
        {
          "name" => "kube-etcd",
          "image" => node['kube']['images']['etcd'],
          "env" => etcd_environment.map { |k, v|
            {
              "name" => k,
              "value" => v
            }
          },
          "volumeMounts" => [
            {
              "mountPath" => "/etc/ssl/certs",
              "name" => "ssl-certs-host",
              "readOnly" => true
            },
            {
              "mountPath" => "/var/lib/etcd",
              "name" => "data-etcd-host",
              "readOnly" => false
            },
            {
              "name" => "etcd-certs",
              "mountPath" => node['kubernetes']['etcd_ssl_path'],
              "readOnly" => false
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "ssl-certs-host",
          "hostPath" => {
            "path" => "/etc/ssl/certs"
          }
        },
        {
          "name" => "data-etcd-host",
          "hostPath" => {
            "path" => "/data/etcd"
          }
        },
        {
          "name" => "etcd-certs",
          "emptyDir" => {}
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd'] = etcd_manifest
end
