execute "pkg_update" do
  command node['sshd']['pkg_update_command']
  action :run
end

package node['sshd']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[sshd]", :delayed
end

sshd_config "docker" do
  config node['sshd']['docker']['config']
  action :create
  notifies :restart, "service[sshd]", :delayed
end

user node['sshd']['docker']['user']['username'] do
  home node['sshd']['docker']['user']['home']
  shell node['sshd']['docker']['user']['shell']
  manage_home true
  action :create
  notifies :deploy, "sshd_git_user_config[docker]", :immediately
end

sshd_git_user_config "docker" do
  user node['sshd']['docker']['user']['username']
  group node['sshd']['docker']['user']['username']
  home node['sshd']['docker']['user']['home']
  git_repo node['sshd']['docker']['user']['git_repo']
  git_branch node['sshd']['docker']['user']['git_branch']
  action :nothing
end

include_recipe "sshd::docker_service"
