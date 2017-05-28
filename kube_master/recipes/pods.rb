node['kube_master']['pods'].each do |f, content|
  file ::File.join(node['kube_master']['manifests_path'], f) do
    content content.to_hash.to_yaml
    action :create
  end
end
