node.default['kubernetes']['kube_master']['base_path'] = '/etc/kubernetes/ssl'

node.default['kubernetes']['kube_master']['ca_path'] = ::File.join(node['kubernetes']['kube_master']['base_path'], 'ca.crt')
node.default['kubernetes']['kube_master']['apiserver_cert_path'] = ::File.join(node['kubernetes']['kube_master']['base_path'], 'apiserver.crt')
node.default['kubernetes']['kube_master']['apiserver_key_path'] = ::File.join(node['kubernetes']['kube_master']['base_path'], 'apiserver.key')
