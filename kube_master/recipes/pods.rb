file ::File.join(node['kube_master']['manifests_path'], "kube-apiserver.yaml") do
  content node['kube_master']['pods']['apiserver'].to_hash.to_yaml
  action :create
end
