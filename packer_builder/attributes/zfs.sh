node.default['packer']['debian_zfs']['scripts'] = [
  "scripts/resolv_hack.sh",
  "scripts/base.sh",
  "scripts/ssh_sshd_config.sh",

  "scripts/install_zfs-jessie.sh",
  "scripts/disk_spindown.sh",
  "scripts/nfs_exports.sh",

  "scripts/install_chef.sh",
  "scripts/etc_chef_mount.sh",
  "scripts/chef_client.sh",

  "scripts/systemd_networking.sh"
]
node.default['packer']['debian_cloud_image']['vm_name'] = 'zfs'
node.default['packer']['debian_cloud_image']['output_directory'] = '/img/kvm'

node.default['packer']['debian_zfs']['builder'] = {
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
           "-- biosdevname=0 net.ifnames=0 console=ttyS0,115200n8 <wait>",
           "<enter><wait>"
        ],
        "disk_size" => 20000,
        "headless" => true,
        "http_directory" => "http",
        "iso_checksum_url" => "https://cdimage.debian.org/debian-cd/{{user `debian_version`}}/amd64/iso-cd/SHA512SUMS",
        "iso_checksum_type" => "sha512",
        "iso_url"=> "https://cdimage.debian.org/debian-cd/{{user `debian_version`}}/amd64/iso-cd/debian-{{user `debian_version`}}-amd64-netinst.iso",
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
        "environment_vars" => [
          "NFS_EXPORTS={{user `nfs_exports`}}",
          "DISK_POWERSAVE={{user `disk_powersave`}}",
          "DISK_SPINDOWN={{user `disk_spindown`}}"
        ],
        "execute_command" => "echo '{{user `password`}}'| {{.Vars}} sudo --preserve-env --stdin sh '{{.Path}}'",
        "scripts" => node['packer']['debian_zfs']['scripts']
      }
    ],
    "variables" => {
      "username" => "debian",
      "uid" => "10000",
      "password" => "password",
      "hostname" => "zfs",
      "domain" => "local",
      "ssh_authorized_keys" => "",
      "debian_version" => "8.7.1",
      "nfs_exports" => "",
      "disk_powersave" => "127",
      "disk_spindown" => "244"
    }
  }
}
