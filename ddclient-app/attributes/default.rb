node.default['ddclient']['pkg_update_command'] = "apt-get update -qqy"
node.default['ddclient']['pkg_names'] = ['ddclient']

node.default['ddclient']['data_bag'] = 'deploy_config'
node.default['ddclient']['data_bag_item'] = 'ddclient'

node.default['ddclient']['freedns_template'] = {
  "daemon" => "10m",
  "use" => "web",
  "web" => "http://icanhazip.com/",
  "web-skip" => '',
  "server" => "freedns.afraid.org",
  "protocol" => "freedns"
  # "login" => "login",
  # "password" => "password",
  # "host.test.local" => nil
}
