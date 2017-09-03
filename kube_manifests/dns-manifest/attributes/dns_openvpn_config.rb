dbag = Dbag::Keystore.new('deploy_config', 'openvpn_pia_v2')

node.default['kube_manifests']['dns']['openvpn_config'] = OpenvpnHelper::ConfigGenerator.generate_from_hash({
  "client" => true,
  "dev" => "tun",
  "proto" => "udp",
  "remote" => ["us-seattle.privateinternetaccess.com", 1194],
  "resolv-retry" => "infinite",
  "nobind"  => true,
  "persist-key" => true,
  "tls-client" => true,
  "remote-cert-tls" => "server",
  "comp-lzo" => true,
  "verb" => 3,
  "reneg-sec" => 0,
  "cipher" => "BF-CBC",
  "keepalive" => [10, 30],
  "route-nopull" => true,
  "redirect-gateway" => true,
  "fast-io" => true,
})

node.default['kube_manifests']['dns']['openvpn_auth_user_pass'] = dbag.get('auth-user-pass').join($/)
node.default['kube_manifests']['dns']['openvpn_ca'] = dbag.get('ca.crt')
