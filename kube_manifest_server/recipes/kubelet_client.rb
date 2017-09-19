[
  'kubectl',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0755'
    action :create_if_missing
  end
end


[
  node['kubernetes']['srv_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


kubelet_kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        "server" => "https://#{node['environment_v2']['set']['gateway']['vip_lan']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubelet-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kubelet"
      }
    }
  ],
  "current-context" => "kubelet-context"
}


## ssl
kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['ca_path']
  action :create
end

kubernetes_admin_cert 'client' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-client"
  key_path node['kubernetes']['key_path']
  cert_path node['kubernetes']['cert_path']
  action :create_if_missing
  subscribes :create, "kubernetes_ca[ca]", :immediately
end


directory ::File.dirname(node['kubernetes']['kubectl']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kubernetes']['kubectl']['kubeconfig_path'] do
  content kubelet_kube_config.to_yaml
  action :create
end
