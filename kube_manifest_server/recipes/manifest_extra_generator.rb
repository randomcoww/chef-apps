[
  node['kubernetes']['manifests_extra_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

node['kubernetes']['extra_configs'].each do |name, manifests|
  if manifests.is_a?(Array)

    kubernetes_pod ::File.join(node['kubernetes']['manifests_extra_path'], name) do
      content manifests.map { |m| m.to_hash.to_yaml }.join($/)
      action :create
    end
  end

end
