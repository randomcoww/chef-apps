music_pv = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolume",
  "metadata" => {
    "name" => "music-nfs-pv"
  },
  "spec" => {
    "capacity" => {
      "storage" => "1Gi"
    },
    "accessModes" => [
      "ReadOnlyMany"
    ],
    "persistentVolumeReclaimPolicy" => "Retain",
    "nfs" => {
      "path" => "/vol/music/brick",
      "server" => node['environment_v2']['set']['nfs']['vip']['store'],
      "readOnly" => true
    }
  }
}

####

music_pvc = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolumeClaim",
  "metadata" => {
    "name" => "music-nfs-pvc"
  },
  "spec" => {
    "accessModes" => [
      "ReadOnlyMany"
    ],
    "resources" => {
      "requests" => {
        "storage" => "1Gi"
      }
    }
  }
}

####

mpd_pv = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolume",
  "metadata" => {
    "name" => "mpd-nfs-pv"
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
      "path" => "/data/pv/mpd",
      "server" => node['environment_v2']['set']['nfs']['vip']['store'],
      "readOnly" => false
    }
  }
}

####

mpd_pvc = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolumeClaim",
  "metadata" => {
    "name" => "mpd-nfs-pvc"
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
    "name" => "mpd"
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "mpd"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "mpd"
        }
      },
      "spec" => {
        "containers" => [
          {
            "name" => "mpd",
            "image" => node['kube']['images']['mpd'],
            "ports" => [
              {
                "containerPort" => 8000,
                "protocol" => "TCP"
              },
              {
                "containerPort" => 6600,
                "protocol" => "TCP"
              }
            ],
            "volumeMounts" => [
              {
                "mountPath" => "/mpd/music",
                "name" => "music-data"
              },
              {
                "mountPath" => "/mpd/cache",
                "name" => "mpd-data"
              }
            ]
          }
        ],
        "volumes" => [
          {
            "name" => "music-data",
            "persistentVolumeClaim" => {
              "claimName" => "music-nfs-pvc"
            }
          },
          {
            "name" => "mpd-data",
            "persistentVolumeClaim" => {
              "claimName" => "mpd-nfs-pvc"
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
    "name" => "mpd-service"
  },
  "spec" => {
    "type" => "NodePort",
    "ports" => [
      {
        "name" => "control",
        "port" => 6600,
        "targetPort" => 6600
      },
      {
        "name" => "stream",
        "port" => 8000,
        "targetPort" => 8000
      }
    ],
    "selector" => {
      "k8s-app" => "mpd"
    }
  }
}


configs = []
configs << music_pv
configs << music_pvc
configs << mpd_pv
configs << mpd_pvc
configs << deploy_config
configs << service_config

node.default['kubernetes']['extra_configs']['mpd'] = configs
