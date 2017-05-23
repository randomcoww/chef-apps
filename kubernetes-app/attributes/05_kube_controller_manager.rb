node.default['kubernetes']['kube_controller_manager']['args'] = [
  "/hyperkube",
  "controller-manager",
  "--master=http://127.0.0.1:8080",
  "--leader-elect=true",
  "--service-account-private-key-file=#{node['kubernetes']['kube_master']['apiserver_key_path']}",
  "--root-ca-file=#{node['kubernetes']['kube_master']['ca_path']}",
]
