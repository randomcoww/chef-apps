execute "pkg_update" do
  command node['transmission']['pkg_update_command']
  action :run
end

## mount the data
directory '/data' do
  recursive true
  action :create
end

mount '/data/' do
  fstype 'glusterfs'
  device '169.254.127.30:/gluster_test'
  action [:mount, :enable]
end

## pre-generate user with desired home, GID and UID to match share on glusterfs
group node['transmission']['main']['group'] do
  gid node['transmission']['main']['gid']
  action :create
end

user node['transmission']['main']['user'] do
  uid node['transmission']['main']['uid']
  gid node['transmission']['main']['gid']
  shell '/bin/false'
  home node['transmission']['main']['home']
  action :create
end

## finally install package and should use existing user
package node['transmission']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[transmission-daemon]", :immediately
end

transmission_config "transmission" do
  config node['transmission']['main']['config']
  action :create
  path node['transmission']['main']['config_path']
  ## trasnmission rewrites the config on service stop
  ## need to stop service before this
  notifies :stop, "service[transmission-daemon]", :before
end

include_recipe "transmission::service"
