node.default['kea']['pkg_update_command'] = "apt-get update -qqy"
node.default['kea']['pkg_names'] = [
  'kea-dhcp4-server',
  'default-libmysqlclient-dev'
]

node.default['kea']['lan_reservations'] = {}
