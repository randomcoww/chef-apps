runcmd = node['qemu']['current_config']['runcmd'] || []

node.default['qemu']['current_config']['runcmd'] = runcmd + [
  "apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common",
  "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
  %Q{add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"},
  "apt-get -y update"
]
