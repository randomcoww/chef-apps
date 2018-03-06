node.default['etcd']['ssl_path'] = '/etc/ssl/localcerts'
node.default['etcd']['cluster_name'] = 'etcd-default'
## cert and auth
node.default['etcd']['ca_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_ca.crt')
node.default['etcd']['cert_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_cert.crt')
node.default['etcd']['key_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_key.key')

node.default['etcd']['ca_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_peer_ca.crt')
node.default['etcd']['cert_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_peer_cert.crt')
node.default['etcd']['key_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd_peer_key.key')
