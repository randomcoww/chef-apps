env_vars = node['environment_v2']['set']['vault']['vars']

vault_config = {
  "storage" => {
    "file" => {
      "path" => "/data/vault_data"
    }
  },
  "listener" => {
    "tcp" => {
      "address" => "0.0.0.0:#{node['environment_v2']['port']['vault']}",
      "tls_cert_file" => "/etc/ssl/certs/internal.pem",
      "tls_key_file"  => "/etc/ssl/certs/internal-key.pem",
      "tls_client_ca_file" => "/etc/ssl/certs/internal-ca.pem"
    }
  }
}

vault_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "vault",
    "namespace" => "kube-system",
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
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
            "name" => "vault-data",
            "mountPath" => "/data"
          },
          {
            "mountPath": "/etc/ssl/certs",
            "name": "ssl-certs-host",
            "readOnly": true
          }
        ],
        # "ports" => [
        #   {
        #     "containerPort" => 8888,
        #     "hostPort" => 8888,
        #     "protocol" => "TCP"
        #   }
        # ]
      }
    ],
    "volumes" => [
      {
        "name" => "vault-data",
        "hostPath" => {
          "path" => env_vars["data_path"]
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => env_vars['ssl_path']
        }
      }
    ]
  }
}

node['environment_v2']['set']['vault']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  vault_config = {
    "api_addr": "https://#{ip}:48889",
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

  vault_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "vault",
      "namespace" => "kube-system",
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "containers" => [
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
              "mountPath": "/etc/ssl/certs",
              "name": "ssl-certs-host",
              "readOnly": true
            }
          ],
          # "ports" => [
          #   {
          #     "containerPort" => 8888,
          #     "hostPort" => 8888,
          #     "protocol" => "TCP"
          #   }
          # ]
        }
      ],
      "volumes" => [
        {
          "name" => "ssl-certs-host",
          "hostPath" => {
            "path" => env_vars['ssl_path']
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['vault'] = vault_manifest
end
