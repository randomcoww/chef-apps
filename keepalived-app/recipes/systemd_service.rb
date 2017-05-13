## override systemd - no support for drop-ins as far as i can tell..
systemd_unit 'keepalived.service' do
  content ({
    'Unit' => {
      'Description' => 'Keepalive Daemon (LVS and VRRP)',
      'After' => 'network-online.target',
      'Wants' => 'network-online.target',
      'BindsTo' => 'systemd-networkd.service',
      'ConditionFileNotEmpty' => '/etc/keepalived/keepalived.conf'
    },
    'Service' => {
      'Restart' => 'always',
      'RestartSec' => 5,
      'Type' => 'forking',
      'KillMode' => 'process',
      'EnvironmentFile' => '-/etc/default/keepalived',
      'ExecStart' => '/usr/sbin/keepalived $DAEMON_ARGS',
      'ExecReload' => '/bin/kill -HUP $MAINPID'
    },
    'Install' => {
      'WantedBy' => 'multi-user.target'
    }
  })
  action [:create, :enable, :start]

  subscribes :stop, "package[#{node['keepalived']['package']}]", :immediately
  subscribes :reload, 'file[keepalived.conf]', :delayed
  subscribes :reload, 'file[keepalived-options]', :delayed
end
