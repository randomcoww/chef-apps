## override this with data mount requiremnt

systemd_unit "transmission-daemon.service" do
  content ({
    'Unit' => {
      'Description' => 'Transmission BitTorrent Daemon',
      'After' => [
        'network.target',
        'data-transmission.mount'
      ],
      'Requires' => [
        'data-transmission.mount'
      ]
    },
    'Service' => {
      "User" => "debian-transmission",
      "Type" => "notify",
      "ExecStart" => "/usr/bin/transmission-daemon -f --log-error",
      "ExecStop" => "/bin/kill -s STOP $MAINPID",
      "ExecReload" => "/bin/kill -s HUP $MAINPID"
    },
    'Install' => {
      "WantedBy" => "multi-user.target"
    }
  })
  action [:create]
end

include_recipe "transmission::service"
