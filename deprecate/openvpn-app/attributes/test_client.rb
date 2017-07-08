node.default['openvpn']['test_client'] = {
  'pkg_names' => ['openvpn'],
  'config' => {
    "client" => true,
    "dev" => "tap",
    "proto" => "udp",
    "remote" => ["192.168.62.239", 1194],
    "resolv-retry" => "infinite",
    "persist-key" => true,
    "persist-tun" => true,
    "ca" => 'ca.crt',
    "cert" => 'client.crt',
    "key" => 'client.key',
    "tls-client" => true,
    "remote-cert-tls" => "server",
    "comp-lzo" => true,
    "verb" => 3,
    "reneg-sec" => 0,
    "cipher" => "AES-256-CBC",
    "auth" => "SHA512",
    "keepalive" => [10, 30],
    "fast-io" => true,
  }
}
