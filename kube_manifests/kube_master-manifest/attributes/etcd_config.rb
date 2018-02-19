# services = {}
#
# lan_domain = [
#   node['environment_v2']['domain']['host'],
#   node['environment_v2']['domain']['top']
# ].join('.')

# node.default['kube_manifests']['etcd']['etcd_servers'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
#   # "https://#{e}.#{lan_domain}:2379"
#   "https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
# }.join(',')
