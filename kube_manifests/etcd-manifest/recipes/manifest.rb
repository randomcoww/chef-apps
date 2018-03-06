#
# etcd ssl
#
etcd_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_ssl', [['CN', 'etcd-ca']]
)
etcd_ca = etcd_cert_generator.root_ca

## peer
etcd_peer_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_peer_ssl', [['CN', 'etcd-peer-ca']]
)
etcd_peer_ca = etcd_peer_cert_generator.root_ca


domain = [
  node['environment_v2']['domain']['host'],
  node['environment_v2']['domain']['top']
].join('.')

san_ips = {}
san_dns = {}

node['environment_v2']['set']['etcd']['hosts'].each.with_index(1) do |host, i|

  san_ips["IP.#{i}"] = node['environment_v2']['host'][host]['ip']['store']
  san_dns["DNS.#{i}"] = [host, domain].join('.')
end

etcd_key = etcd_cert_generator.generate_key
etcd_cert = etcd_cert_generator.node_cert(
  [
    ['CN', "etcd"]
  ],
  etcd_key,
  {
    "basicConstraints" => "CA:FALSE",
    "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
  },
  san_dns.merge(san_ips)
)

##
## etcd peer ssl
##
etcd_peer_key = etcd_peer_cert_generator.generate_key
etcd_peer_cert = etcd_peer_cert_generator.node_cert(
  [
    ['CN', "etcd-peer"]
  ],
  etcd_peer_key,
  {
    "basicConstraints" => "CA:FALSE",
    "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
  },
  san_dns.merge(san_ips)
)


#
# ssl init containers
#

etcd_init_container_manifest = {
  node['etcd']['ca_path'] => etcd_ca.to_pem,
  node['etcd']['key_path'] => etcd_key.to_pem,
  node['etcd']['cert_path'] => etcd_cert.to_pem
}.map { |path, c|
  {
    "name" => "etcd-ssl#{path.gsub(/[\/._]/, '-')}",
    "image" => node['kube']['images']['envwriter'],
    "env" => [
      {
        "name" => "DATA",
        "value" => c
      },
    ],
    "args" => [
      path
    ],
    "volumeMounts" => [
      {
        "name" => "local-certs",
        "mountPath" => node['etcd']['ssl_path'],
      }
    ]
  }
}

etcd_peer_init_container_manifest = {
  node['etcd']['ca_peer_path'] => etcd_peer_ca.to_pem,
  node['etcd']['key_peer_path'] => etcd_peer_key.to_pem,
  node['etcd']['cert_peer_path'] => etcd_peer_cert.to_pem
}.map { |path, c|
  {
    "name" => "etcd-peer-ssl#{path.gsub(/[\/._]/, '-')}",
    "image" => node['kube']['images']['envwriter'],
    "env" => [
      {
        "name" => "DATA",
        "value" => c
      },
    ],
    "args" => [
      path
    ],
    "volumeMounts" => [
      {
        "name" => "local-certs",
        "mountPath" => node['etcd']['ssl_path'],
      }
    ]
  }
}


## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")

node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => "/var/lib/etcd",

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['etcd']['cluster_name'],

    "ETCD_TRUSTED_CA_FILE" => node['etcd']['ca_path'],
    "ETCD_CERT_FILE" => node['etcd']['cert_path'],
    "ETCD_KEY_FILE" => node['etcd']['key_path'],

    "ETCD_PEER_TRUSTED_CA_FILE" => node['etcd']['ca_peer_path'],
    "ETCD_PEER_CERT_FILE" => node['etcd']['cert_peer_path'],
    "ETCD_PEER_KEY_FILE" => node['etcd']['key_peer_path'],

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
      "initContainers" => (etcd_init_container_manifest + etcd_peer_init_container_manifest),
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
              "name" => "local-certs",
              "mountPath" => node['etcd']['ssl_path'],
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
          "name" => "local-certs",
          "emptyDir" => {}
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd'] = etcd_manifest
end
