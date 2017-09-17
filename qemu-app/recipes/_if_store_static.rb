current_host = node['qemu']['current_config']['hostname']
interface = node['environment_v2']['host'][current_host]['if_store']

node.default['qemu']['current_config']['networking'][interface] = {
  "Match" => {
    "Name" => interface
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "no"
  },
  "Address" => {
    "Address" => "#{node['environment_v2']['host'][current_host]['ip_store']}/#{node['environment_v2']['subnet']['store'].split('/').last}"
  }
}

node.default['qemu']['current_config']['libvirt_networks'][interface] = {
  "#attributes"=>{
    "type"=>"direct",
    "trustGuestRxFilters"=>"yes"
  },
  "source"=>{
    "#attributes"=>{
      "dev"=>node['environment_v2']['current_host']['if_store'],
      "mode"=>"bridge"
    }
  },
  "model"=>{
    "#attributes"=>{
      "type"=>"virtio-net"
    }
  }
}