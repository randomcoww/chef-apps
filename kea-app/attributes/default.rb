node.default['kea']['pkg_update_command'] = "apt-get update -qqy"
node.default['kea']['pkg_names'] = [
  'kea-dhcp4-server',
  'default-libmysqlclient-dev'
]

node.default['kea']['lan_reservations'] = {
  "52:54:00:ac:da:f3" => "192.168.62.99"
}
