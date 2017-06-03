node.default['qemu']['current_config']['hostname'] = 'haproxy2'
include_recipe "qemu-app::template_haproxy"
