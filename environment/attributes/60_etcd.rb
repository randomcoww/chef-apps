node.default['etcd']['ssl_path'] = '/etc/ssl/localcerts'
node.default['etcd']['cluster_name'] = 'etcd-default'
## cert and auth
node.default['etcd']['ca_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd-ca.pem')
node.default['etcd']['cert_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd.pem')
node.default['etcd']['key_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd-key.pem')

node.default['etcd']['ca_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd-peer-ca.pem')
node.default['etcd']['cert_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd-peer.pem')
node.default['etcd']['key_peer_path'] = ::File.join(node['etcd']['ssl_path'], 'etcd-peer-key.pem')
