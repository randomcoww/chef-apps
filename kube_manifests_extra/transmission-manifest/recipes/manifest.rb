torrent_pv = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolume",
  "metadata" => {
    "name" => "torrent-nfs-pv"
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
      "path" => "/vol/torrent",
      "server" => node['environment_v2']['set']['nfs']['vip']['store'],
      "readOnly" => false
    }
  }
}

torrent_pvc = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolumeClaim",
  "metadata" => {
    "name" => "torrent-nfs-pvc"
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

transmission_pv = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolume",
  "metadata" => {
    "name" => "transmission-nfs-pv"
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
      "path" => "/data/pv/transmission",
      "server" => node['environment_v2']['set']['nfs']['vip']['store'],
      "readOnly" => false
    }
  }
}

transmission_pvc = {
  "apiVersion" => "v1",
  "kind" => "PersistentVolumeClaim",
  "metadata" => {
    "name" => "transmission-nfs-pvc"
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
    "name" => "transmission"
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "transmission"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "transmission"
        }
      },
      "spec" => {
        "restartPolicy" => "Always",
        "dnsPolicy" => "ClusterFirst",
        ## use this when available
        # "dnsPolicy" => "None",
        # "dnsConfig" => {
        #   "nameservers" => [
        #     "8.8.8.8",
        #     "8.8.4.4"
        #   ]
        # },
        "volumes" => [
          {
            "name" => "torrent-data",
            "persistentVolumeClaim" => {
              "claimName" => "torrent-nfs-pvc"
            }
          },
          {
            "name" => "transmission-data",
            "persistentVolumeClaim" => {
              "claimName" => "transmission-nfs-pvc"
            }
          },
          {
            "name" => "nettun",
            "hostPath" => {
              "path" => "/dev/net/tun"
            }
          }
        ],
        "initContainers" => [
          {
            "name" => "nftables",
            "image" => node['kube']['images']['nftables'],
            "securityContext" => {
              "capabilities" => {
                "add" => [
                  "NET_ADMIN"
                ]
              }
            },
            "env" => [
              {
                "name" => "CONFIG",
                "value" => node['kube_manifests']['transmission']['nftables_config'],
              }
            ]
          }
        ],
        "containers" => [
          {
            "name" => "openvpn",
            "image" => node['kube']['images']['openvpn'],
            "securityContext" => {
              "capabilities" => {
                "add" => [
                  "NET_ADMIN"
                ]
              }
            },
            "args" => [
              "--route 192.168.0.0 255.255.0.0 net_gateway",
              "--route 10.3.0.0 255.255.255.0 net_gateway",
              "--route 10.244.0.0 255.255.0.0 net_gateway"
            ],
            "env" => [
              {
                "name" => "OVPN_CONFIG",
                "value" => node['kube_manifests']['transmission']['openvpn_config']
              },
              {
                "name" => "OVPN_AUTH_USER_PASS",
                "value" => node['kube_manifests']['transmission']['openvpn_auth']
              },
              {
                "name" => "OVPN_CRL_VERIFY",
                "value" => node['kube_manifests']['transmission']['openvpn_crl']
              },
              {
                "name" => "OVPN_CA",
                "value" => node['kube_manifests']['transmission']['openvpn_ca']
              }
            ],
            "volumeMounts" => [
              {
                "mountPath" => "/dev/net/tun",
                "name" => "nettun"
              }
            ]
          },
          {
            "name" => "transmission",
            "image" => node['kube']['images']['transmission'],
            "ports" => [
              {
                "containerPort" => 9091
              }
            ],
            "volumeMounts" => [
              {
                "mountPath" => node['kube_manifests']['transmission']['data_path'],
                "name" => "torrent-data"
              },
              {
                "mountPath" => "/var/lib/transmission",
                "name" => "transmission-data"
              }
            ],
            "env" => [
              {
                "name" => "CONFIG",
                "value" => node['kube_manifests']['transmission']['transmission_config']
              }
            ]
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
    "name" => "transmission-service"
  },
  "spec" => {
    "type" => "NodePort",
    "ports" => [
      {
        "name" => "webui",
        "port" => 9091,
        "targetPort" => 9091
      }
    ],
    "selector" => {
      "k8s-app" => "transmission"
    }
  }
}


configs = []
configs << torrent_pv
configs << torrent_pvc
configs << transmission_pv
configs << transmission_pvc
configs << deploy_config
configs << service_config

node.default['kubernetes']['extra_configs']['transmission'] = configs
