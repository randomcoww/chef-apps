node.default['openvpn']['server'] = {
  'pkg_names' => ['openvpn'],
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
    "dh" => 'dh.pem'
  }
}
