node.default['environment_v2']['service']['transmission'] = {
  "bind" => 9091,
  "sets" => {
    "kube-master" => 30063
  }
}

node.default['environment_v2']['service']['sshd'] = {
  "bind" => 2222,
  "sets" => {
    "kube-master" => 32222
  }
}

node.default['environment_v2']['service']['mpd_control'] = {
  "bind" => 6600,
  "sets" => {
    "kube-master" => 30061
  }
}

node.default['environment_v2']['service']['mpd_stream'] = {
  "bind" => 8000,
  "sets" => {
    "kube-master" => 30062
  }
}

node.default['environment_v2']['service']['kube_master'] = {
  "bind" => node['kubernetes']['secure_port'],
  "sets" => {
    "kube-master" => node['kubernetes']['secure_port']
  }
}

node.default['environment_v2']['service']['manifest_server'] = {
  "bind" => 8888
}
