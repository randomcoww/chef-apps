node.default['qemu']['current_config']['hostname'] = 'haproxy1'
include_recipe "qemu-app::template_haproxy"
