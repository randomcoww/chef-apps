node.default['kube_master']['docker']['pkg_names'] = ['docker-engine']

node.default['kube_master']['docker']['systemd_dropin'] = {
  'Unit' => {
    'After' => 'flannel.service',
    'Requires' => 'flannel.service',
    'ConditionFileNotEmpty' => node['kube_master']['flannel']['environment']['FLANNELD_SUBNET_FILE']
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "EnvironmentFile" => node['kube_master']['flannel']['environment']['FLANNELD_SUBNET_FILE'],
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --log-driver=journald"
    ]
  }
}
