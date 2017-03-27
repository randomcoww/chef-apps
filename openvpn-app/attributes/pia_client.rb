node.default['openvpn']['pia_client'] = {
  'config' => {
    "client" => true,
    "dev" => "tun",
    "proto" => "udp",
    "remote" => ["us-seattle.privateinternetaccess.com", 1194],
    "resolv-retry" => "infinite",
    "nobind"  => true,
    "persist-key" => true,
    "ca" => 'ca.crt',
    "tls-client" => true,
    "remote-cert-tls" => "server",
    "auth-user-pass" => 'client_auth',
    "comp-lzo" => true,
    "verb" => 3,
    "reneg-sec" => 0,
    "cipher" => "BF-CBC",
    "keepalive" => [10, 30],
    "route-nopull" => true,
    "redirect-gateway" => true,
    "fast-io" => true,
  },
  'auth-user-pass' => {
    'data_bag' => 'deploy_config',
    'data_bag_item' => 'openvpn_pia_v2',
    'key' => 'auth-user-pass'
  },
  'ca' => {
    'data_bag' => 'deploy_config',
    'data_bag_item' => 'openvpn_pia_v2',
    'key' => 'ca.crt'
  }
}
