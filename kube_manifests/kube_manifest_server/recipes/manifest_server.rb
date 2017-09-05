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

    pod_list = {
      "apiVersion" => "v1",
      "kind" => "PodList",
      "items" => manifests.values.map { |m| m.to_hash }
    }

    kubernetes_pod ::File.join(node['kubernetes']['manifests_path'], host) do
      config pod_list
      action :create
    end
  end

end
