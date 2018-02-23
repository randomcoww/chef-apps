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


node['environment_v2']['set']['dns']['hosts'].uniq.each do |host|

  directories = []

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    }
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
            "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
            %Q{RKT_RUN_ARGS="#{[
              "--uuid-file-save=/var/run/kubelet-pod.uuid",
              "--volume var-log,kind=host,source=/var/log",
              "--mount volume=var-log,target=/var/log",
              "--volume dns,kind=host,source=/etc/resolv.conf",
              "--mount volume=dns,target=/etc/resolv.conf",
            ].join(' ')}"}
          ],
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /etc/kubernetes/manifests",
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/lib/coreos/kubelet-wrapper",
            "--register-node=true",
            "--cni-conf-dir=/etc/kubernetes/cni/net.d",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--docker-disable-shared-pid=false"
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
