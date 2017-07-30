node.default['qemu']['current_config']['hostname'] = 'dns1'
include_recipe "qemu-app::template_dns"
