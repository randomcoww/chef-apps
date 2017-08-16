node.default['qemu']['current_config']['hostname'] = 'unifi'
include_recipe "qemu-app::template_unifi"
