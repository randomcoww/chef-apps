# references
# https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md

ssl_config = {
  "signing" => {
    "default" => {
      "auth_key" => "key1",
      "expiry" => "26280h"
    },
    "profiles" => {
      "intermediate" => {
        "expiry" => "43800h",
        "usages" => [
          "signing",
          "key encipherment",
          "cert sign",
          "crl sign"
        ],
        "ca_constraint" => {
          "is_ca" => true,
          "max_path_len" => 1
        }
      },
      "kubernetes" => {
        "usages" => [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ],
        "expiry" => "8760h"
      },
      "server" => {
        "auth_key" => "key1",
        "expiry" => "43800h",
        "usages" => [
          "signing",
          "key encipherment",
          "server auth"
        ]
      },
      "client" => {
        "auth_key" => "key1",
        "expiry" => "43800h",
        "usages" => [
          "signing",
          "key encipherment",
          "client auth"
        ]
      },
      "peer" => {
        "auth_key" => "key1",
        "expiry" => "43800h",
        "usages" => [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
        ]
      }
    }
  },
  "auth_keys" => {
    "key1" => {
      "key" => "245f62575040243f3d544926562f4a5d",
      "type" => "standard"
    }
  }
}.to_json


cfssl_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "cfssl"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "cfssl",
        "image" => node['kube']['images']['cfssl'],
        "command" => [
          "/serve_wrapper.sh"
        ],
        "args" => [
          # "serve",
          "-address",
          "0.0.0.0",
          "-ca",
          "/certs/root_ca/root_ca.pem",
          "-ca-key",
          "/certs/root_ca/root_ca-key.pem",
          # "-config",
          # "/certs/config.json",
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => ssl_config
          }
        ],
        "volumeMounts" => [
          {
            "name" => "certs",
            "mountPath" => "/certs"
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
        "name" => "certs",
        "hostPath" => {
          "path" => "/data/certs"
        }
      }
    ]
  }
}

node['environment_v2']['set']['ca']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['cfssl'] = cfssl_manifest
end
