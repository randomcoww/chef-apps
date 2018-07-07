## Deprecated - replaced with https://github.com/randomcoww/terraform

## chef-environment

Configuration source for https://github.com/randomcoww/environment-config

Build all:

    recipe[generic-qemu::qemu],
    recipe[qemu_config_server::qemu_server],
    recipe[etcd-ign::ignition],
    recipe[gateway-ign::ignition],
    recipe[kube_master-ign::ignition],
    recipe[kube_worker-ign::ignition],
    recipe[ignition_config_server::ignition_server],
    recipe[ns-manifest::manifest],
    recipe[gateway-manifest::manifest],
    recipe[kea-manifest::manifest],
    recipe[kube_master-manifest::manifest],
    recipe[kube_worker-manifest::manifest],
    recipe[keepalived-manifest::manifest],
    recipe[kube_manifest_server::manifest_server],
