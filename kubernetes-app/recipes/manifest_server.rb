[
  node['kubernetes']['manifests_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

node['kubernetes']['static_pods'].each do |host, manifests|

  if manifests.is_a?(Hash)
    content = manifests.values.map { |m| m.to_hash.to_yaml }.join($/)

    kubernetes_pod ::File.join(node['kubernetes']['manifests_path'], host) do
      content content
      action :create
    end
  end

end
