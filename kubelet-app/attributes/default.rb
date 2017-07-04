node.default['kubernetes']['docker']['systemd_dropin'] = {
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --log-driver=journald"
      # "/usr/bin/dockerd -H fd:// --log-driver=journald --ip-masq=false --iptables=false"
    ]
  }
}
