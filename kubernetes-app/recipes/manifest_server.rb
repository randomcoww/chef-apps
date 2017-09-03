node['kubernetes']['static_pods'].each do |host, manifests|
  path = ::File.join(node['kubernetes']['manifests_path'], host)

  directory path do
    recursive true
    action [:create]
  end

  Dir.entries(path).each do |f|
    next unless manifests.has_key?(f)

    file = ::File.join(path, f)
    next unless ::File.file?(file)

    kubernetes_pod file do
      action :delete
    end
  end

  manifests.each do |f, config|
    kubernetes_pod ::File.join(path, f) do
      config config
      action :create
    end
  end

end
