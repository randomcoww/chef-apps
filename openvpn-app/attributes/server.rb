node.default['openvpn']['server'] = {
  'config' => {
    "port" => 1194,
    "proto" => "udp",
    "dev" => "tap",
    "tls-server" => true,
    "mode" => "server",
    "keepalive" => [10, 120],
    "comp-lzo" => true,
    "user" => "nobody",
    "group" => "nogroup",
    "persist-key" => true,
    "cipher" => "AES-256-CBC",
    "auth" => "SHA512",
    "verb" => 3,
    "ca" => 'ca.crt',
    "cert" => 'server.crt',
    "key" => 'server.key',
    "dh" => 'dh'
  },
  'data_bag' => 'deploy_config',
  'data_bag_item' => 'openvpn_server',
  'label' => 'default',
  'cert_variables' => {
    "KEY_COUNTRY" => "XX",
    "KEY_PROVINCE" => "YY",
    "KEY_CITY" => "BlahCity",
    "KEY_ORG" => "BlahOrg",
    "KEY_EMAIL" => "blah@test.local",
    "KEY_OU" => "BlahOU"
  }
}
