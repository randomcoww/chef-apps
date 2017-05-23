etcd_servers = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')

node.default['kubernetes']['kube_apiserver']['service_ip_range'] = '10.254.0.0/16'

node.default['kubernetes']['kube_apiserver']['args'] = [
  "/hyperkube",
  "apiserver",
  "--bind-address=0.0.0.0",
  "--etcd-servers=#{etcd_servers}",
  "--allow-privileged=true",
  "--service-cluster-ip-range=#{node['kubernetes']['kube_apiserver']['service_ip_range']}",
  "--secure-port=443",
  "--advertise-address=#{node['kubernetes']['node_ip']}",
  "--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota",
  # "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota",
  "--tls-cert-file=#{node['kubernetes']['kube_master']['apiserver_cert_path']}",
  "--tls-private-key-file=#{node['kubernetes']['kube_master']['apiserver_key_path']}",
  "--client-ca-file=#{node['kubernetes']['kube_master']['ca_path']}",
  "--service-account-key-file=#{node['kubernetes']['kube_master']['apiserver_key_path']}",
  # "--runtime-config=extensions/v1beta1/networkpolicies=true",
  # "--anonymous-auth=false"
]
