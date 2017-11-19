node.default['environment_v2']['haproxy']['transmission'] = {
  "port" => 9091
}

node.default['environment_v2']['haproxy']['sshd'] = {
  "port" => 2222
}

node.default['environment_v2']['haproxy']['mpd-control'] = {
  "port" => 6600
}

node.default['environment_v2']['haproxy']['mpd-stream'] = {
  "port" => 8000
}

node.default['environment_v2']['haproxy']['kube-master'] = {
  "port" => 24443
}

# node.default['environment_v2']['haproxy']['etcd-client-ssl'] = {
#   "port" => 2379
# }
