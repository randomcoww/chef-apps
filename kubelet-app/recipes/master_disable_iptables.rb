node.default['kubernetes']['docker']['systemd_dropin'] = {
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --log-driver=journald --iptables=false"
    ]
  }
}

include_recipe "kubernetes-app::_docker"

include_recipe "kubelet-app::_kubelet"
include_recipe "kubelet-app::_static_pods"
