node.default['environment_v2']['service']['transmission'] = {
  "port" => 9091
}

node.default['environment_v2']['service']['sshd'] = {
  "port" => 2222
}

node.default['environment_v2']['service']['mpd-control'] = {
  "port" => 6600
}

node.default['environment_v2']['service']['mpd-stream'] = {
  "port" => 8000
}

node.default['environment_v2']['service']['kube-master'] = {
  "port" => 443
}

node.default['environment_v2']['service']['etcd-client'] = {
  "port" => 2379
}

node.default['environment_v2']['service']['kube-dns'] = {
  "port" => 53530
}
