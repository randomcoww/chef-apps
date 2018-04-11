env_vars = node['environment_v2']['set']['matchbox']['vars']

# ceph_monitors = node['environment_v2']['set']['ceph-mon']['hosts'].map { |e|
#   "#{node['environment_v2']['host'][e]['ip']['store']}:6789"
# }

node['environment_v2']['set']['matchbox']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  data_path = "/var/lib/matchbox"
  assets_path = "/var/lib/matchbox/assets"
  # assets_path = "/assets"

  matchbox_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "name" => "matchbox"
    },
    "spec" => {
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "matchbox",
          "image" => node['kube']['images']['matchbox'],
          "args" => [
            "-address=0.0.0.0:48080",
            "-rpc-address=0.0.0.0:48081",
            "-ca-file=#{node['kubernetes']['etcd_ssl_base_path']}-ca.pem",
            "-cert-file=#{node['kubernetes']['etcd_ssl_base_path']}.pem",
            "-key-file=#{node['kubernetes']['etcd_ssl_base_path']}-key.pem",
            "-data-path=#{data_path}",
            "-assets-path=#{assets_path}",
          ],
          "volumeMounts" => [
            {
              "mountPath" => "/etc/ssl/certs",
              "name" => "ssl-certs-host",
              "readOnly" => true
            },
            {
              "mountPath" => data_path,
              "name" => "data-matchbox",
              "readOnly" => false
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
          "name" => "data-matchbox",
          "nfs" => {
            "server" => node['environment_v2']['set']['nfs']['vip']['store'],
            "path" => "/data/matchbox"
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['matchbox'] = matchbox_manifest
end
