node.default['qemu']['current_config']['systemd_config']['/etc/systemd/system/chef-client.service'] = {
  "Unit" => {
    "Description" => "Chef Client daemon",
    "After" => "network.target auditd.service"
  },
  "Service" => {
    "Type" => "oneshot",
    "ExecStart" => "/usr/bin/chef-client -o #{node['qemu']['current_config']['chef_recipes'].join(',')}",
    "ExecReload" => "/bin/kill -HUP $MAINPID",
    "SuccessExitStatus" => 3
  }
}

node.default['qemu']['current_config']['systemd_config']['/etc/systemd/system/chef-client.timer'] = {
  "Unit" => {
    "Description" => "chef-client periodic run"
  },
  "Install" => {
    "WantedBy" => "timers.target"
  },
  "Timer" => {
    "OnStartupSec" => "1min",
    "OnUnitActiveSec" => node['qemu']['current_config']['chef_interval']
  }
}
