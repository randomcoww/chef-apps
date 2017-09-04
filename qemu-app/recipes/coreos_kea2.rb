node.default['qemu']['current_config']['hostname'] = 'coreos-kea2'
include_recipe "qemu-app::template_coreos_kube_worker"
