pv = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolume",
  "metadata" => {
    "name" => "unifi-nfs-pv"
  },
  "spec" => {
    "capacity" => {
      "storage" => "1Gi"
    },
    "accessModes" => [
      "ReadWriteMany"
    ],
    "persistentVolumeReclaimPolicy" => "Retain",
    "nfs" => {
      "path" => "/data/pv/unifi",
      "server" => node['environment_v2']['set']['nfs']['vip']['store'],
      "readOnly" => false
    }
  }
}

####

pvc = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolumeClaim",
  "metadata" => {
    "name" => "unifi-nfs-pvc"
  },
  "spec" => {
    "accessModes" => [
      "ReadWriteMany"
    ],
    "resources" => {
      "requests" => {
        "storage" => "1Gi"
      }
    }
  }
}

####

deploy_config = {
  "kind" => "Deployment",
  "apiVersion" => "extensions/v1beta1",
  "metadata" => {
    "name" => "unifi"
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "unifi"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "unifi"
        }
      },
      "spec" => {
        "restartPolicy" => "Always",
        "dnsPolicy" => "ClusterFirst",
        "containers" => [
          {
            "name" => "unifi",
            "image" => node['kube']['images']['unifi'],
            "ports" => [
              {
                "containerPort" => 8080,
                "protocol" => "TCP"
              },
              {
                "containerPort" => 8443,
                "protocol" => "TCP"
              }
            ],
            "volumeMounts" => [
              {
                "mountPath" => "/opt/UniFi/data",
                "name" => "unifi-data"
              }
            ]
          }
        ],
        "volumes" => [
          {
            "name" => "unifi-data",
            "persistentVolumeClaim" => {
              "claimName" => "unifi-nfs-pvc"
            }
          }
        ]
      }
    }
  }
}

####

service_config = {
  "kind" => "Service",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "unifi-service"
  },
  "spec" => {
    "type" => "NodePort",
    "ports" => [
      {
        "name" => "http",
        "port" => 8080,
        "targetPort" => 8080
      },
      {
        "name" => "https",
        "port" => 8443,
        "targetPort" => 8443
      }
    ],
    "selector" => {
      "k8s-app" => "unifi"
    }
  }
}


configs = []
configs << pv
configs << pvc
configs << deploy_config
configs << service_config

node.default['kubernetes']['extra_configs']['unifi'] = configs
