include_recipe "transmission-app::mounts"

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

directory ::File.dirname(node['transmission']['main']['config_path']) do
  recursive true
  owner node['transmission']['main']['user']
  group node['transmission']['main']['group']
  action :create
end

transmission_config "transmission" do
  config node['transmission']['main']['config']
  action :create
  path node['transmission']['main']['config_path']
  ## trasnmission rewrites the config on service stop
  ## need to stop service before this
  notifies :stop, "service[transmission-daemon]", :before
end

include_recipe "transmission-app::service"
