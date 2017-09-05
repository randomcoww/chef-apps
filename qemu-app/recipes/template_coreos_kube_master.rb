# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['ignition_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}.ign"

node.default['qemu']['current_config']['ignition_config'] = {
  "passwd" => {
    "users" => [
      {
        "name" => "core",
        "passwordHash" => "$6$c6en5k51$fJnDYVaIDbasJQNWo.ezDdX4zfW9jsVlZAQwztQbMvRVUei/iGfGzBlhxqCAWCI6kAkrQLwy2Yr6D9HImPWWU/"
      }
    ]
  }
}

include_recipe "qemu-app::_kube_master_certs"

node.default['qemu']['current_config']['ignition_files'] = [
  {
    "path" => "/etc/hostname",
    "mode" => 420,
    "contents" => "data:,#{node['qemu']['current_config']['hostname']}"
  },
  {
    "path" => node['kubernetes']['key_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_master_key'])}"
  },
  {
    "path" => node['kubernetes']['cert_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_master_cert'])}"
  },
  {
    "path" => node['kubernetes']['ca_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_ca'])}"
  }
]

node.default['qemu']['current_config']['ignition_networkd'] = [
  {
    "name" => "ens2",
    "contents" => {
      "Match" => {
        "Name" => "ens2"
      },
      "Network" => {
        "LinkLocalAddressing" => "no",
        "DHCP" => "no",
        "DNS" => (node['environment_v2']['set']['dns']['hosts'].map { |host|
          node['environment_v2']['host'][host]['ip_lan']
        } + [ '8.8.8.8' ])
      },
      "Address" => {
        "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
      },
      "Route" => {
        "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
      }
    }
  }
]


flanneld_environment = {
  "FLANNELD_IFACE" => node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan'],
  "FLANNELD_ETCD_ENDPOINTS" => node['environment_v2']['set']['etcd_flannel']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(','),
  "FLANNELD_ETCD_PREFIX" => '/docker_overlay/network',
  "FLANNELD_SUBNET_DIR" => '/run/flannel/networks',
  "FLANNELD_SUBNET_FILE" => '/run/flannel/subnet.env',
  "FLANNELD_IP_MASQ" => true
}

flanneld_network = {
  "Network" => node['kubernetes']['cluster_cidr'],
  "Backend" => {
    "Type" => "vxlan"
  }
}

node.default['qemu']['current_config']['ignition_systemd'] = [
  {
    "name" => "kubelet",
    "contents" => {
      "Service" => {
        "Environment" => [
          "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
          %Q{RKT_RUN_ARGS="#{[
            "--uuid-file-save=/var/run/kubelet-pod.uuid",
            "--volume var-log,kind=host,source=/var/log",
            "--mount volume=var-log,target=/var/log",
            "--volume dns,kind=host,source=/etc/resolv.conf",
            "--mount volume=dns,target=/etc/resolv.conf"
          ].join(' ')}"}
        ],
        "ExecStartPre" => [
          "/usr/bin/mkdir -p /etc/kubernetes/manifests",
          "/usr/bin/mkdir -p /var/log/containers",
          "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
        ],
        "ExecStart" => [
          "/usr/lib/coreos/kubelet-wrapper",
          "--api-servers=http://127.0.0.1:8080",
          "--register-schedulable=false",
          "--cni-conf-dir=/etc/kubernetes/cni/net.d",
          "--network-plugin=${NETWORK_PLUGIN}",
          "--container-runtime=docker",
          "--allow-privileged=true",
          "--manifest-url=http://#{node['environment_v2']['current_host']['ip_lan']}:8888/#{node['qemu']['current_config']['hostname']}",
          "--hostname-override=#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']}",
          "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
          "--cluster_domain=#{node['kubernetes']['cluster_domain']}"
        ].join(' '),
        "ExecStop" => "-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid",
        "Restart" => "always",
        "RestartSec" => 10
      },
      "Install" => {
        "WantedBy" => "multi-user.target"
      }
    }
  },
  {
    "name" => "flanneld",
    "dropins" => [
      {
        "name" => "etcd-env",
        "contents" => {
          "Service" => {
            "Environment" => flanneld_environment.map { |k, v|
              "#{k}=#{v}"
            },
            "ExecStartPre" => "/usr/bin/etcdctl --endpoints=#{flanneld_environment['FLANNELD_ETCD_ENDPOINTS']} set #{flanneld_environment['FLANNELD_ETCD_PREFIX']}/config '#{flanneld_network.to_json}'",
          }
        }
      }
    ]
  },
  {
    "name" => "docker",
    "dropins" => [
      {
        "name" => "flannel",
        "contents" => {
          "Unit" => {
            "Requires" => "flanneld.service",
            "After" => "flanneld.service"
          },
          "Service" => {
            "Environment" => [
              %Q{DOCKER_OPT_BIP=""},
              %Q{DOCKER_OPT_IPMASQ=""}
            ]
          }
        }
      }
    ]
  }
]


include_recipe "qemu-app::_libvirt_coreos"
include_recipe "qemu-app::_deploy_coreos"
