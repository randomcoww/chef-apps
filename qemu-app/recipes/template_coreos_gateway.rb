# node.default['qemu']['current_config']['hostname'] = 'host'
current_host = node['qemu']['current_config']['hostname']

node.default['qemu']['current_config']['ignition_config_path'] = "/data/cloud-init/#{current_host}.ign"

node.default['qemu']['current_config']['ignition_config'] = {
  "passwd" => {
    "users" => [
      {
        "name" => "core",
        # "passwordHash" => "$6$c6en5k51$fJnDYVaIDbasJQNWo.ezDdX4zfW9jsVlZAQwztQbMvRVUei/iGfGzBlhxqCAWCI6kAkrQLwy2Yr6D9HImPWWU/",
        "sshAuthorizedKeys" => node['environment_v2']['ssh_authorized_keys']['default']
      }
    ]
  }
}

include_recipe "qemu-app::_kube_worker_certs"


t = Tempfile.new('/tmp')
template t.path do
  source 'nft.erb'
  variables ({
    current_host: node['environment_v2']['host'][current_host],
    sets: node['environment_v2']['set'],
    hosts: node['environment_v2']['host']
  })
  action :nothing
end.run_action(:create)

t.close
nftables_config = IO.binread(t.path).gsub(/\t/, "  ")
nftables_path = "/etc/nft.rules"


sysctl_config = [
  "net.ipv4.ip_forward=1",
  "net.ipv4.ip_nonlocal_bind=1"
].join($/)


node.default['qemu']['current_config']['ignition_files'] = [
  {
    "path" => "/etc/hostname",
    "mode" => 420,
    "contents" => "data:,#{current_host}"
  },
  {
    "path" => node['kubernetes']['key_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_worker_key'])}"
  },
  {
    "path" => node['kubernetes']['cert_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_worker_cert'])}"
  },
  {
    "path" => node['kubernetes']['ca_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['qemu']['current_config']['kube_ca'])}"
  },
  {
    "path" => node['kubernetes']['kubelet']['kubeconfig_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['kube_worker']['kubelet']['kubeconfig'].to_hash.to_yaml)}"
  },
  {
    "path" => node['kubernetes']['kube_proxy']['kubeconfig_path'],
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(node['kube_worker']['kube_proxy']['kubeconfig'].to_hash.to_yaml)}"
  },
  {
    "path" => nftables_path,
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(nftables_config)}"
  },
  {
    "path" => "/etc/sysctl.d/ipforward.conf",
    "mode" => 420,
    "contents" => "data:;base64,#{Base64.encode64(sysctl_config)}"
  }
]


node.default['qemu']['current_config']['networking'] ||= []
node.default['qemu']['current_config']['ignition_networkd'] = node['qemu']['current_config']['networking'].map { |name, contents|
  {
    "name" => name,
    "contents" => contents
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
            "--mount volume=dns,target=/etc/resolv.conf",
            "--volume ssl,kind=host,source=#{node['kubernetes']['srv_path']}",
            "--mount volume=ssl,target=#{node['kubernetes']['srv_path']}"
          ].join(' ')}"}
        ],
        "ExecStartPre" => [
          "/usr/bin/mkdir -p /etc/kubernetes/manifests",
          "/usr/bin/mkdir -p /var/log/containers",
          "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
        ],
        "ExecStart" => [
          "/usr/lib/coreos/kubelet-wrapper",
          # "--api-servers=http://#{node['kubernetes']['master_ip']}",
          "--register-schedulable=false",
          # "--cni-conf-dir=/etc/kubernetes/cni/net.d",
          # "--network-plugin=${NETWORK_PLUGIN}",
          "--container-runtime=docker",
          "--allow-privileged=true",
          "--manifest-url=http://#{node['environment_v2']['current_host']['ip_lan']}:8888/#{current_host}",
          "--hostname-override=#{node['environment_v2']['host'][current_host]['ip_lan']}",
          # "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
          # "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
          # "--kubeconfig=#{node['kubernetes']['kubelet']['kubeconfig_path']}",
          # "--tls-cert-file=#{node['kubernetes']['cert_path']}",
          # "--tls-private-key-file=#{node['kubernetes']['key_path']}",
          "--make-iptables-util-chains=false"
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
    "name" => "docker",
    "dropins" => [
      {
        "name" => "iptables",
        "contents" => {
          "Service" => {
            "Environment" => [
              "DOCKER_OPTS=--iptables=false"
            ]
          }
        }
      }
    ]
  },
  {
    "name" => "nftables",
    "contents" => {
      "Unit" => {
        "Wants" => "network-pre.target",
        "Before" => "network-pre.target"
      },
      "Service" => {
        "Type" => "oneshot",
        "ExecStartPre" => "-/usr/sbin/nft flush ruleset",
        "ExecStart" => "/usr/sbin/nft -f #{nftables_path}",
        "ExecStop" => "/usr/sbin/nft flush ruleset",
        "RemainAfterExit" => "yes"
      },
      "Install" => {
        "WantedBy" => "multi-user.target"
      }
    }
  }
]


include_recipe "qemu-app::_libvirt_coreos"
include_recipe "qemu-app::_deploy_coreos"
