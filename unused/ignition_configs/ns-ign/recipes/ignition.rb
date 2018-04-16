base = {
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


# kube_config = {
#   "apiVersion" => "v1",
#   "kind" => "Config",
#   "clusters" => [
#     {
#       "name" => node['kubernetes']['cluster_name'],
#       "cluster" => {
#         "server" => "http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
#       }
#     }
#   ],
#   "users" => [
#     {
#       "name" => "kube",
#     }
#   ],
#   "contexts" => [
#     {
#       "name" => "kube-context",
#       "context" => {
#         "cluster" => node['kubernetes']['cluster_name'],
#         "user" => "kube"
#       }
#     }
#   ],
#   "current-context" => "kube-context"
# }
#
#
# cni_conf = JSON.pretty_generate(node['kubernetes']['cni_conf'].to_hash)
# flannel_cfg = JSON.pretty_generate(node['kubernetes']['flanneld_conf'].to_hash)


node['environment_v2']['set']['dns']['hosts'].uniq.each do |host|

  ip = node['environment_v2']['host'][host]['ip']['store']

  directories = []

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    # ## flannel
    # {
    #   "path" => node['kubernetes']['flanneld_conf_path'],
    #   "mode" => 420,
    #   "contents" => "data:;base64,#{Base64.encode64(flannel_cfg)}"
    # },
    # {
    #   "path" => node['kubernetes']['cni_conf_path'],
    #   "mode" => 420,
    #   "contents" => "data:;base64,#{Base64.encode64(cni_conf)}"
    # },
    # ## kubeconfig
    # {
    #   "path" => node['kubernetes']['client']['kubeconfig_path'],
    #   "mode" => 420,
    #   "contents" => "data:;base64,#{Base64.encode64(kube_config.to_hash.to_yaml)}"
    # },
  ]


  networkd = []

  interfaces = node['environment_v2']['host'][host]['if'].to_hash.dup

  interfaces.each do |i, interface|

    addr = node['environment_v2']['host'][host]['ip'][i]
    gw = node['environment_v2']['host'][host]['gw'][i]

    if !interface.nil? &&
      !addr.nil? &&
      !gw.nil?

      subnet_mask = node['environment_v2']['subnet'][i].split('/').last

      networkd << {
        "name" => "#{interface}.network",
        "contents" => {
          "Match" => {
            "Name" => interface
          },
          "Network" => {
            "LinkLocalAddressing" => "no",
            "DHCP" => "no",
            "DNS" => [
              '127.0.0.1',
              '8.8.8.8'
            ]
          },
          "Address" => {
            "Address" => "#{addr}/#{subnet_mask}"
          },
          "Route" => {
            "Gateway" => gw,
            "Metric" => 2048
          }
        }
      }
    end
  end

  systemd = [
    {
      "name" => "kubelet.service",
      "contents" => {
        "Service" => {
          "Environment" => [
            "KUBELET_IMAGE=docker://#{node['kube']['images']['hyperkube']}",
            %Q{RKT_RUN_ARGS="#{[
              "--insecure-options=image",
              "--uuid-file-save=/var/run/kubelet-pod.uuid",
              # "--volume var-log,kind=host,source=/var/log",
              # "--mount volume=var-log,target=/var/log",
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
            # "--register-node=true",
            # "--cni-conf-dir=#{::File.dirname(node['kubernetes']['cni_conf_path'])}",
            # "--network-plugin=cni",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            # "--hostname-override=#{ip}",
            # "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            # "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            # "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
            "--docker-disable-shared-pid=false",
            "--image-gc-high-threshold=0",
            "--image-gc-low-threshold=0",
            # "--feature-gates=CustomPodDNS=true"
          ].join(' '),
          "ExecStop" => "-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid",
          "Restart" => "always",
          "RestartSec" => 10
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      }
    }
  ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'directories' => directories,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
