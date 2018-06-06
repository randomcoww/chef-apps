# references
# https://coreos.com/os/docs/latest/generate-self-signed-certificates.html
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md

env_vars = node['environment_v2']['set']['cfssl']['vars']
ca_base = ::File.join(env_vars["ssl_path"], "ca")
ssl_base = ::File.join(env_vars["ssl_path"], "cfssl")

ssl_config = {
  "signing" => {
    "default" => {
      "expiry" => "8760h"
    },
    "profiles" => {
      "kubernetes" => {
        "usages" => ["signing", "key encipherment", "server auth", "client auth"],
        "expiry" => "8760h"
      }
    }
  }
}.to_json


cfssl_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "cfssl",
    "namespace" => "kube-system",
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
          "-address=0.0.0.0",
          "-port=#{node['environment_v2']['port']['cfssl']}",
          "-ca=#{ca_base}.pem",
          "-ca-key=#{ca_base}-key.pem",
          "-tls-cert=#{ssl_base}.pem",
          "-tls-key=#{ssl_base}-key.pem",
          # "-config=/certs/config.json",
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => ssl_config
          }
        ],
        "volumeMounts" => [
          {
            "mountPath" => env_vars["ssl_path"],
            "name" => "ssl-cfssl",
            "readOnly" => false
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "ssl-cfssl",
        "hostPath" => {
          "path" => env_vars["ssl_path"]
        }
      }
    ]
  }
}

node['environment_v2']['set']['cfssl']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['cfssl'] = cfssl_manifest
end
