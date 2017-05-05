directory '/data/transmission' do
  recursive true
  action :create
end

systemd_unit "data-transmission.mount" do
  content ({
    'Unit' => {
      "Description" => "Mount transmission share"
    },
    'Mount' => {
      "What" => "#{node['environment_v2']['vip']['gluster_store']}:/ctorrent",
      "Where" => node['transmission']['main']['home'],
      "Type" => "glusterfs"
    }
  })
  action [:create]
end

## there appears to be some race condition with regular mount and
## dependent service during reboot automount resolves this
systemd_unit "data-transmission.automount" do
  content ({
    'Unit' => {
      "Description" => "Automount transmission share"
    },
    'Automount' => {
      "Where" => node['transmission']['main']['home']
    },
    'Install' => {
      "WantedBy" => "multi-user.target"
    }
  })
  action [:create, :enable, :start]
end
