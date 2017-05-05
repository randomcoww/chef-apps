require 'chef/mixin/shell_out'

profile = node['system_update']['debian']
profile['commands'].each do |e|
  Chef::Log.info("Run update #{e} #{profile['opts']}")
  r = Mixlib::ShellOut.new(e, profile['opts'])
  # r.live_stdout = $stdout
  r.run_command
  Chef::Log.info(r.stdout)
end
