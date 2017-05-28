node['kube_master']['manifests'].each do |f, config|
  kubernetes_pod ::File.join(node['kube_master']['manifests_path'], f) do
    config config
    action :create
  end
end
