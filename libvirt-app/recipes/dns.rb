execute "pkg_update" do
  command node['libvirt']['pkg_update_command']
  action :run
end

package node['libvirt']['pkg_names'] do
  action :upgrade
end

include_recipe "libvirt::install"

libvirt_qemu 'dns' do
  config node['libvirt']['dns']
  action :start
end
