## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")

env_vars = node['environment_v2']['set']['etcd']['vars']


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  vault_config = {
    "api_addr": "https://#{ip}:#{node['environment_v2']['port']['vault']}",
    "storage": {
      "etcd": {
        "ha_enabled": "true",
        "address": "https://#{ip}:2379",
        "etcd_api": "v3",
        "tls_cert_file": "#{node['kubernetes']['etcd_ssl_base_path']}.pem",
        "tls_key_file": "#{node['kubernetes']['etcd_ssl_base_path']}-key.pem",
        "tls_ca_file": "#{node['kubernetes']['etcd_ssl_base_path']}-ca.pem"
      }
    },
    "listener" => {
      "tcp" => {
        "address" => "0.0.0.0:#{node['environment_v2']['port']['vault']}",
        "tls_cert_file" => "#{node['kubernetes']['etcd_ssl_base_path']}.pem",
        "tls_key_file"  => "#{node['kubernetes']['etcd_ssl_base_path']}-key.pem",
        "tls_client_ca_file" => "#{node['kubernetes']['etcd_ssl_base_path']}-ca.pem"
      }
    }
  }

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => "/var/lib/etcd/default",

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379,https://127.0.0.1:2379",
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
            }
          ]
        },
        {
          "name" => "vault",
          "image" => node['kube']['images']['vault'],
          "securityContext" => {
            "capabilities" => {
              "add" => [
                "IPC_LOCK"
              ]
            }
          },
          "args" => [
            "server",
          ],
          "env" => [
            {
              "name" => "VAULT_LOCAL_CONFIG",
              "value" => vault_config.to_json
            }
          ],
          "volumeMounts" => [
            {
              "mountPath" => "/etc/ssl/certs",
              "name" => "ssl-certs-host",
              "readOnly" => true
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "ssl-certs-host",
          "hostPath" => {
            "path" => env_vars["ssl_path"]
          }
        },
        {
          "name" => "data-etcd-host",
          "hostPath" => {
            "path" => env_vars["data_path"]
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd'] = etcd_manifest
end
