package node['qemu']['pkg_names'] do
  action :nothing
end.run_action(:install)

include_recipe "qemu::install"


## libvirt networks
{
  node['qemu']['libvirt_network_lan'] => node['environment_v2']['current_host']['vf_lan'],
  node['qemu']['libvirt_network_wan'] => node['environment_v2']['current_host']['vf_wan'],
  node['qemu']['libvirt_network_store'] => node['environment_v2']['current_host']['vf_store']
}.each do |name, dev|

  qemu_network name do
    config ({
      "network"=>{
        "name"=>{
          "#text"=>name
        },
        "forward"=>{
          "#attributes"=>{
            "mode"=>"hostdev",
            "managed"=>"yes"
          },
          "pf"=>{
            "#attributes"=>{
              "dev"=>dev
            }
          }
        }
      }
    })
    action :start
  end
end


## ignition
qemu_ignition_config node['qemu']['current_config']['hostname'] do
  path node['qemu']['current_config']['ignition_config_path']
  networkd node['qemu']['current_config']['ignition_networkd']
  systemd node['qemu']['current_config']['ignition_systemd']
  systemd_dropins node['qemu']['current_config']['ignition_systemd_dropins']
  files node['qemu']['current_config']['ignition_files']
  base node['qemu']['current_config']['ignition_config']
  action :create
end


## libvirt domain
qemu_domain node['qemu']['current_config']['hostname'] do
  config node['qemu']['current_config']['libvirt_coreos']
  action :start
end
