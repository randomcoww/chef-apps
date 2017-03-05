execute "pkg_update" do
  command node['kea']['pkg_update_command']
  action :run
end

package node['kea']['pkg_names'] do
  action :upgrade
end

node['kea']['instances'].each do |name, v|
  kea name do
    config v['config']
    action :deploy
  end
end
