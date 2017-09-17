require 'open-uri'

include_recipe "qemu::install"

host = node['qemu']['current_config']['hostname']
config_host = "http://#{node['environment_v2']['host'][node['hostname']]['ip_lan']}"

libvirt_config = open("#{config_host}:8889/libvirt/#{host}").read
ignition_config = open("#{config_host}:8889/ignition/#{host}").read

## libvirt networks
{
  node['qemu']['libvirt_network_lan'] => node['environment_v2']['host'][node['hostname']]['vf_lan'],
  node['qemu']['libvirt_network_wan'] => node['environment_v2']['host'][node['hostname']]['vf_wan'],
  node['qemu']['libvirt_network_store'] => node['environment_v2']['host'][node['hostname']]['vf_store']
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
file "#{::File.join(node['qemu']['ignition_path'], host)}.ign" do
  content ignition_config
  action :create
end

## libvirt domain
qemu_domain host do
  xml libvirt_config
  action :start
end
