node.default['qemu']['current_config']['hostname'] = 'dns2'
include_recipe "qemu-app::template_dns"
