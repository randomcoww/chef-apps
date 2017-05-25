node.default['kubernetes']['kube_worker']['base_path'] = '/etc/kubernetes/ssl'

node.default['kubernetes']['kube_worker']['ca_path'] = ::File.join(node['kubernetes']['kube_worker']['base_path'], 'ca.crt')
node.default['kubernetes']['kube_worker']['worker_cert_path'] = ::File.join(node['kubernetes']['kube_worker']['base_path'], 'worker.crt')
node.default['kubernetes']['kube_worker']['worker_key_path'] = ::File.join(node['kubernetes']['kube_worker']['base_path'], 'worker.key')
