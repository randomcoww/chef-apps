node.default['docker_overlay']['docker']['pkg_names'] = ['docker-engine']

node.default['docker_overlay']['docker']['systemd_dropin'] = {
  'Unit' => {
    'After' => 'flanneld.service'
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "EnvironmentFile" => "/run/flannel/subnet.env",
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --log-driver=journald"
    ]
  }
}
