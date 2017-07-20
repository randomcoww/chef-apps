node.override['kubernetes']['docker']['systemd_dropin'] = {
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --log-driver=journald --iptables=true"
    ]
  }
}

node.override['kubernetes']['kubelet']['systemd'] = {
  'Unit' => {
    'Description' => 'Kubelet'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      node['kubernetes']['kubelet']['binary_path'],
      "--pod-manifest-path=#{node['kubernetes']['manifests_path']}",
      "--allow-privileged=true"
    ].join(' ')
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
