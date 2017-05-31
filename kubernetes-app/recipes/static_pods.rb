node['kubernetes']['static_pods'].each do |f, config|
  kubernetes_pod ::File.join(node['kubernetes']['manifests_path'], f) do
    config config
    action :create
  end
end
