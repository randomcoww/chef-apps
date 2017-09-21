require 'open-uri'

include_recipe "qemu::install"

# {
#   node['qemu']['libvirt_network_lan'] => node['environment_v2']['host'][node['hostname']]['vf_lan'],
#   node['qemu']['libvirt_network_wan'] => node['environment_v2']['host'][node['hostname']]['vf_wan'],
#   node['qemu']['libvirt_network_store'] => node['environment_v2']['host'][node['hostname']]['vf_store']
# }.each do |name, dev|
#
#   qemu_network name do
#     config ({
#       "network"=>{
#         "name"=>{
#           "#text"=>name
#         },
#         "forward"=>{
#           "#attributes"=>{
#             "mode"=>"hostdev",
#             "managed"=>"yes"
#           },
#           "pf"=>{
#             "#attributes"=>{
#               "dev"=>dev
#             }
#           }
#         }
#       }
#     })
#     action :start
#   end
# end

config_host = node['environment_v2']['host'][node['hostname']]['ip_lan']
start_domains = {}

libvirt_configs = open("http://#{config_host}:#{node['environment_v2']['service']['manifest_server']['bind']}/libvirt/#{node['hostname']}").read
YAML.load(libvirt_configs).each do |e|
  start_domains[e['name']] = e['contents']
end


LibvirtWrapper::LibvirtDomain.get_all_domains.each do |d|
  next if !d.exists?
  next if start_domains.has_key?(d.name)
  next if !d.active?

  d.shutdown_or_destroy(300)
end

start_domains.each do |name, content|
  d = LibvirtWrapper::LibvirtDomain.get_or_define_from_xml(content)
  next if !d.exists?
  next if d.active?

  d.start(300)
end
