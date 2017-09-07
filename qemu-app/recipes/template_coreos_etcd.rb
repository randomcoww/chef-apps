# node.default['qemu']['current_config']['hostname'] = 'host'
current_host = node['qemu']['current_config']['hostname']
current_ip = node['environment_v2']['host'][current_host]['ip_lan']

node.default['qemu']['current_config']['ignition_config_path'] = "/data/cloud-init/#{current_host}.ign"

node.default['qemu']['current_config']['ignition_config'] = {
  "passwd" => {
    "users" => [
      {
        "name" => "core",
        # "passwordHash" => "$6$c6en5k51$fJnDYVaIDbasJQNWo.ezDdX4zfW9jsVlZAQwztQbMvRVUei/iGfGzBlhxqCAWCI6kAkrQLwy2Yr6D9HImPWWU/",
        "sshAuthorizedKeys" => node['environment_v2']['ssh_authorized_keys']['default']
      }
    ]
  }
}


node.default['qemu']['current_config']['ignition_files'] = [
  {
    "path" => "/etc/hostname",
    "mode" => 420,
    "contents" => "data:,#{current_host}"
  }
]

node.default['qemu']['current_config']['networking'] ||= []
node.default['qemu']['current_config']['ignition_networkd'] = node['qemu']['current_config']['networking'].map { |name, contents|
  {
    "name" => name,
    "contents" => contents
  }
}

etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |host|
  "#{host}=http://#{node['environment_v2']['host'][host]['ip_lan']}:2380"
}


node.default['qemu']['current_config']['ignition_systemd'] = [
  {
    "name" => "etcd-member",
    "dropins" => [
      {
        "name" => "etcd-env",
        "contents" => {
          "Service" => {
            "Environment" => [
              %Q{ETCD_OPTS="#{[
                "--name=#{current_host}",
                "--listen-peer-urls=http://#{current_ip}:2380",
                "--listen-client-urls=#{[current_ip, '127.0.0.1'].map { |e|
                    "http://#{e}:2379"
                  }.join(',')}",
                "--initial-advertise-peer-urls=http://#{current_ip}:2380",
                "--initial-cluster=#{etcd_initial_cluster.join(',')}",
                "--initial-cluster-state=new",
                "--initial-cluster-token=etcd-1",
                "--advertise-client-urls=http://#{current_ip}:2379"
              ].join(' ')}"}
            ]
          }
        }
      }
    ]
  }
]


include_recipe "qemu-app::_libvirt_coreos"
include_recipe "qemu-app::_deploy_coreos"
