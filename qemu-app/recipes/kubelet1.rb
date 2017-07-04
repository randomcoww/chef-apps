node.default['qemu']['current_config']['hostname'] = 'kubelet1'
include_recipe "qemu-app::template_kubelet"
