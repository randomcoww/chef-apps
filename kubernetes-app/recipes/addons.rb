node['kubernetes']['addons'].each do |f, config|
  kubernetes_pod ::File.join(node['kubernetes']['addons_path'], f) do
    config config
    action :create
  end
end

Dir.entries(node['kubernetes']['addons_path']).each do |f|
  next if node['kubernetes']['addons'].has_key?(f)

  path = ::File.join(node['kubernetes']['addons_path'], f)
  next unless ::File.file?(path)

  kubernetes_pod path do
    config ({})
    action :delete
  end
end
