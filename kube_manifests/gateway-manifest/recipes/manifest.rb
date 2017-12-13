nftables_rules = []

node['environment_v2']['subnet'].each do |e, v|
  nftables_rules << "define subnet_#{e} = #{v}"
end

node['environment_v2']['set'].each do |e, v|
  if v['vip'].is_a?(Hash)
    v['vip'].each do |i, v|

      nftables_rules << "define vip_#{e}_#{i} = #{v}"
    end
  end
end


node['environment_v2']['set']['gateway']['hosts'].each do |host|
  node['environment_v2']['host'][host]['if'].each do |i, v|
    nftables_rules << "define host_if_#{i} = #{v}"
  end

  nftables_rules << ''


  gateway_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "nftables"
    },
    "spec" => {
      "restartPolicy" => "OnFailure",
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "nftables",
          "image" => node['kube']['images']['nftables'],
          "securityContext" => {
            "capabilities" => {
              "add" => [
                "NET_ADMIN"
              ]
            }
          },
          "env" => [
            {
              "name" => "CONFIG",
              "value" => nftables_rules.join($/) +
                node['kube_manifests']['gateway']['nftables_config']
            }
          ]
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['gateway'] = gateway_manifest
end
