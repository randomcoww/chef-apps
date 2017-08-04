node.default['kubelet']['static_pods']['etcd.yaml'] = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "etcd"
  },
  "spec" => {
    "hostNetwork" => true,
    "restartPolicy" => 'Always',
    "containers" => [
      {
        "name" => "kube-etcd",
        "image" => "quay.io/coreos/etcd:latest",
        "command" => [
          "/usr/local/bin/etcd",
          "--data-dir=/var/lib/etcd"
        ],
        "env" => node['kubelet']['etcd']['environment'].map { |k, v|
          {
            "name" => k,
            "value" => v
          }
        },
        "volumeMounts" => [
          {
            "mountPath" => "/var/lib/etcd",
            "name" => "etcd-data"
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "etcd-data",
        "emptyDir" => {}
      }
    ]
  }
}
