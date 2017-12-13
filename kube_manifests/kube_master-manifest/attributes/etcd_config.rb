services = {}

lan_domain = [
  node['environment_v2']['domain']['host'],
  node['environment_v2']['domain']['top']
].join('.')

node.default['kube_manifests']['etcd']['etcd_servers'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
  "https://#{e}.#{lan_domain}:#{node['environment_v2']['set']['etcd']['services']['etcd-client-ssl']['port']}"
}.join(',')
