node.override['kubernetes']['docker']['systemd_dropin'] = {
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "EnvironmentFile" => node['kubernetes']['flannel']['environment']['FLANNELD_SUBNET_FILE'],
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --log-driver=journald --ip-masq=false --iptables=false"
    ]
  }
}
