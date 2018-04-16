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


kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "server" => "http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube",
    }
  ],
  "contexts" => [
    {
      "name" => "kube-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kube"
      }
    }
  ],
  "current-context" => "kube-context"
}


cni_conf = JSON.pretty_generate(node['kubernetes']['cni_conf'].to_hash)
flannel_cfg = JSON.pretty_generate(node['kubernetes']['flanneld_conf'].to_hash)


node['environment_v2']['set']['kube-master']['hosts'].each do |host|

  directories = []

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## flannel
    {
      "path" => node['kubernetes']['flanneld_conf_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(flannel_cfg)}"
    },
    {
      "path" => node['kubernetes']['cni_conf_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(cni_conf)}"
    },
    ## kubeconfig
    {
      "path" => node['kubernetes']['client']['kubeconfig_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(kube_config.to_hash.to_yaml)}"
    }
  ]

  networkd = []

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
            "--register-node=true",
            "--cni-conf-dir=#{::File.dirname(node['kubernetes']['cni_conf_path'])}",
            "--network-plugin=cni",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--hostname-override=${DEFAULT_IPV4}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
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
