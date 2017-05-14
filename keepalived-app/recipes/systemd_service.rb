## override systemd - no support for drop-ins as far as i can tell..

systemd_resource_dropin "10-network_bind" do
  service "keepalived.service"
  config ({
    'Unit' => {
      'BindsTo' => 'systemd-networkd.service',
    },
    'Service' => {
      'Restart' => 'always'
    }
  })
  action [:create]
end

include_recipe "keepalived::service"
