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
  "bind" => 443,
  "sets" => {
    "kube-master" => 443
  }
}