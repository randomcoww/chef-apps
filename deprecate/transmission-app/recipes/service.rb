## override this with data mount requiremnt

systemd_resource_dropin "10-mounts" do
  service "transmission-daemon.service"
  config ({
    'Unit' => {
      'After' => [
        'data-transmission.mount'
      ],
      'BindsTo' => [
        'data-transmission.mount'
      ]
    }
  })
  action [:create]
end

include_recipe "transmission::service"
