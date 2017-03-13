node.default['packer']['debian_cloud_image']['scripts'] = [
  "scripts/resolv_hack.sh",
  "scripts/base.sh",
  "scripts/ssh_sshd_config.sh",

  "scripts/sysctl.sh",
  "scripts/iptables_blacklist.sh",

  "scripts/install_chef.sh",
  "scripts/chef-secret-mount.sh",
  "scripts/chef-client.sh",

  "scripts/install_cloud-init.sh",
  "scripts/cloud-init-mount.sh",

  "scripts/systemd_networking.sh"
]
node.default['packer']['debian_cloud_image']['vm_name'] = 'cloud-image'
node.default['packer']['debian_cloud_image']['output_directory'] = '/img/kvm'

node.default['packer']['debian_cloud_image']['builder'] = {
  "builders" => [
    {
      "boot_command" => [
         "<esc><wait>",
         "install <wait>",
         "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-testing-preseed.cfg <wait>",
         "debian-installer=en_US <wait>",
         "auto <wait>",
         "locale=en_US <wait>",
         "kbd-chooser/method=us <wait>",
         "netcfg/get_hostname={{user `hostname`}} <wait>",
         "netcfg/get_domain={{user `domain`}} <wait>",
         "fb=false <wait>",
         "debconf/frontend=noninteractive <wait>",
         "console-setup/ask_detect=false <wait>",
         "console-keymaps-at/keymap=us <wait>",
         "keyboard-configuration/xkb-keymap=us <wait>",

         "passwd/user-fullname={{user `username`}} <wait>",
         "passwd/username={{user `username`}} <wait>",
         "passwd/user-uid={{user `uid`}} <wait>",
         "passwd/user-password={{user `password`}} <wait>",
         "passwd/user-password-again={{user `password`}} <wait>",
         "-- biosdevname=0 net.ifnames=0 console=ttyS0,115200n8 elevator=noop <wait>",
         "<enter><wait>"
      ],
      "disk_size" => 20000,
      "headless" => true,
      "http_directory" => "http",
      "iso_checksum_url" => "http://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/SHA512SUMS",
      "iso_checksum_type" => "sha512",
      "iso_url"=> "http://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-cd/debian-testing-amd64-netinst.iso",
      "shutdown_command" => "echo '{{user `password`}}'| sudo --stdin /sbin/halt -p",
      "disk_interface" => "virtio",
      "net_device" => "virtio-net",
      "ssh_username" => "{{user `username`}}",
      "ssh_password" => "{{user `password`}}",
      "ssh_wait_timeout" => "3600s",
      "type" => "qemu",
      "qemuargs" => [[ "-m", "1024M" ],[ "-smp", "2" ]],
      "accelerator" => "kvm",
      "vm_name" => node['packer']['debian_cloud_image']['vm_name'],
      "format" => "qcow2",
      "output_directory" => node['packer']['debian_cloud_image']['output_directory']
    }
  ],
  "provisioners"=> [
    {
      "pause_before" => "5s",
      "type" => "shell",
      "execute_command"=> "echo '{{user `password`}}'| {{.Vars}} sudo --preserve-env --stdin sh '{{.Path}}'",
      "scripts" => node['packer']['debian_cloud_image']['scripts']
    }
  ],
  "variables"=> {
    "username"=> "debian",
    "uid"=> "10000",
    "password"=> "password",
    "hostname"=> "debian-cloud-image",
    "domain"=> "local"
  }
}
