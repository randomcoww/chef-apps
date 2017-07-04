node.default['qemu']['current_config']['hostname'] = 'kubelet2'
include_recipe "qemu-app::template_kubelet"
