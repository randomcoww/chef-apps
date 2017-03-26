node.default['transmission']['pkg_update_command'] = "apt-get update -qqy"
node.default['transmission']['pkg_names'] = ['transmission-daemon']

node.default['transmission']['main']['incomplete-dir'] = "/data/transmission/incomplete"
node.default['transmission']['main']['watch-dir'] = "/data/transmission/watch"
node.default['transmission']['main']['downloads-dir'] = "/data/transmission/downloads"
# node.default['transmission']['main']['info-dir'] = "/data/transmission"

node.default['transmission']['main']['user'] = 'debian-transmission'
node.default['transmission']['main']['group'] = 'debian-transmission'
node.default['transmission']['main']['uid'] = 10006
node.default['transmission']['main']['gid'] = 10006

node.default['transmission']['main']['home'] = "/data/transmission"
node.default['transmission']['main']['config_path'] = ::File.join(node['transmission']['main']['home'], '.config/transmission-daemon/settings.json')

node.default['transmission']['main']['config'] = {
  "alt-speed-down" => 1900,
  "alt-speed-enabled" => true,
  "alt-speed-time-begin" => 540,
  "alt-speed-time-day" => 127,
  "alt-speed-time-enabled" => false,
  "alt-speed-time-end" => 1020,
  "alt-speed-up" => 10,
  "bind-address-ipv4" => "0.0.0.0",
  "bind-address-ipv6" => "::",
  "blocklist-enabled" => false,
  "blocklist-url" => "http://www.example.com/blocklist",
  "cache-size-mb" => 4,
  "dht-enabled" => true,
  "download-dir" => node['transmission']['main']['downloads-dir'],
  "download-limit" => 100,
  "download-limit-enabled" => 0,
  "download-queue-enabled" => true,
  "download-queue-size" => 5,
  "encryption" => 1,
  "idle-seeding-limit" => 30,
  "idle-seeding-limit-enabled" => false,
  "incomplete-dir" => node['transmission']['main']['incomplete-dir'],
  "incomplete-dir-enabled" => true,
  "lpd-enabled" => false,
  "max-peers-global" => 200,
  "message-level" => 1,
  "peer-congestion-algorithm" => "",
  "peer-id-ttl-hours" => 6,
  "peer-limit-global" => 34919,
  "peer-limit-per-torrent" => 16959,
  "peer-port" => 51413,
  "peer-port-random-high" => 65535,
  "peer-port-random-low" => 49152,
  "peer-port-random-on-start" => false,
  "peer-socket-tos" => "default",
  "pex-enabled" => true,
  "port-forwarding-enabled" => false,
  "preallocation" => 1,
  "prefetch-enabled" => true,
  "queue-stalled-enabled" => true,
  "queue-stalled-minutes" => 30,
  "ratio-limit" => 2,
  "ratio-limit-enabled" => false,
  "rename-partial-files" => true,
  "rpc-authentication-required" => false,
  "rpc-bind-address" => "0.0.0.0",
  "rpc-enabled" => true,
  "rpc-port" => 9091,
  "rpc-url" => "/transmission/",
  "rpc-username" => "transmission",
  "rpc-whitelist" => "127.0.0.1",
  "rpc-whitelist-enabled" => false,
  "scrape-paused-torrents-enabled" => true,
  "script-torrent-done-enabled" => false,
  "script-torrent-done-filename" => "",
  "seed-queue-enabled" => false,
  "seed-queue-size" => 10,
  "speed-limit-down" => 100,
  "speed-limit-down-enabled" => false,
  "speed-limit-up" => 100,
  "speed-limit-up-enabled" => false,
  "start-added-torrents" => false,
  "trash-original-torrent-files" => false,
  "umask" => 18,
  "upload-limit" => 100,
  "upload-limit-enabled" => 0,
  "upload-slots-per-torrent" => 14,
  "utp-enabled" => true,
  "watch-dir" => node['transmission']['main']['watch-dir'],
  "watch-dir-enabled" => true
}
