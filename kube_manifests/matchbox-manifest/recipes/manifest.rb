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
      "http://#{node['environment_v2']['host'][e]['ip']['store']}:#{node['environment_v2']['port']['ca']}"
    }.join(',')
  }
}.to_json


node['environment_v2']['set']['matchbox']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  #
  # matchbox ssl
  #
  ssl_csr = {
    "CN" => host,
    "hosts" => [
      ip,
      "127.0.0.1"
    ],
    "key" => {
      "algo" => "ecdsa",
      "size" => 256
    }
  }.to_json

  data_path = "/var/lib/matchbox"
  cert_base_path = "/internalcerts"
  cert_path = ::File.join(cert_base_path, "server")

  matchbox_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "name" => "matchbox"
    },
    "spec" => {
      "hostNetwork" => true,
      "initContainers" => [
        {
          "name" => "cfssl-matchbox",
          "image" => node['kube']['images']['cfssl'],
          "command" => [
            "/gencert_wrapper.sh"
          ],
          "args" => [
            "-p",
            "peer",
            "-o",
            cert_path
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
              "name" => "matchbox-certs",
              "mountPath" => cert_base_path,
              "readOnly" => false
            }
          ]
        }
      ],
      "containers" => [
        {
          "name" => "matchbox",
          "image" => node['kube']['images']['matchbox'],
          "args" => [
            "-address",
            "0.0.0.0:48080",
            "-rpc-address",
            "0.0.0.0:48081",
            "-ca-file",
            "#{cert_path}-ca.pem",
            "cert-file",
            "#{cert_path}.pem",
            "key-file",
            "#{cert_path}-key.pem",
            "-data-path",
            data_path,
            "-assets-path",
            ::File.join(data_path, "assets")
          ],
          "volumeMounts" => [
            {
              "name" => "matchbox-certs",
              "mountPath" => cert_base_path,
              "readOnly" => true
            },
            {
              "name" => "data-path",
              "mountPath" => data_path,
              "readOnly" => false
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "matchbox-certs",
          "emptyDir" => {}
        },
        {
          "name" => "data-path",
          "hostPath" => {
            "path" => data_path
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['matchbox'] = matchbox_manifest
end
