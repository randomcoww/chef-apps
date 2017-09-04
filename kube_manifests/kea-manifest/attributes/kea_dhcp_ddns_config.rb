dbag = Dbag::Keystore.new('deploy_config', 'rndc_keys')

node.default['kube_manifests']['kea']['dhcp_ddns_config'] = {
  "DhcpDdns" => {
    "ip-address" => "127.0.0.1",
    "port" => 53001,
    "dns-server-timeout" => 100,
    "ncr-protocol" => "UDP",
    "ncr-format" => "JSON",
    "tsig-keys" => [
      {
        "name" => "update_key",
        "algorithm" => "HMAC-SHA512",
        "secret" => dbag.get_or_create('update_key', SecureRandom.base64)
      }
    ],
    "forward-ddns" => {
      "ddns-domains" => [
        {
          "name" => [
            node['environment_v2']['domain']['host_lan'],
            node['environment_v2']['domain']['top'],
            ''
          ].join('.'),
          "key-name" => "update_key",
          "dns-servers" => node['environment_v2']['set']['dns']['hosts'].map { |host|
            {
              "ip-address" => node['environment_v2']['host'][host]['ip_lan'],
              "port" => 53530
            }
          }
        }
      ]
    },
    "reverse-ddns" => {
      "ddns-domains" => [ ]
    }
  }
}
