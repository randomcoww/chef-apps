deploy_config = {
  "kind" => "Deployment",
  "apiVersion" => "extensions/v1beta1",
  "metadata" => {
    "name" => "sshd"
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "sshd"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "sshd"
        }
      },
      "spec" => {
        "restartPolicy" => "Always",
        "dnsPolicy" => "ClusterFirst",
        "containers" => [
          {
            "name" => "sshd",
            "image" => node['kube']['images']['sshd'],
            "env" => [
              {
                "name" => "AUTHORIZED_KEYS",
                "value" => node['environment_v2']['ssh_authorized_keys']['default'].join($/)
              },
              {
                "name" => "LOGIN",
                "value" => "randomcoww"
              }
            ],
            "ports" => [
              {
                "protocol" => "TCP",
                "containerPort" => 22
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
  "apiVersion" => "v1",
  "kind" => "Service",
  "metadata" => {
    "name" => "sshd-service",
    "labels" => {
      "name" => "sshd-pod"
    }
  },
  "spec" => {
    "type" => "NodePort",
    "ports" => [
      {
        "port" => 2222,
        "targetPort" => 22
      }
    ],
    "selector" => {
      "k8s-app" => "sshd"
    }
  }
}


configs = []
configs << deploy_config
configs << service_config

node.default['kubernetes']['extra_configs']['sshd'] = configs
