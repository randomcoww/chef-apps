ddclient_bag = Dbag::Keystore.new('kube_manifests', 'ddclient')

ddclient_config = DdclientHelper::ConfigGenerator.generate_from_hash({
  "daemon" => "10m",
  "use" => "web",
  "web" => "dynamicdns.park-your-domain.com/getip",
  "protocol" => "namecheap",
  "server" => "dynamicdns.park-your-domain.com",
  "login" => ddclient_bag.get("login"),
  "password" => ddclient_bag.get("password"),
  ddclient_bag.get("domain") => nil
})

deploy_config = {
  "kind" => "Deployment",
  "apiVersion" => "extensions/v1beta1",
  "metadata" => {
    "name" => 'ddclient'
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => 'ddclient'
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => 'ddclient'
        }
      },
      "spec" => {
        "restartPolicy" => "Always",
        "dnsPolicy" => "ClusterFirst",
        "containers" => [
          {
            "name" => 'ddclient',
            "image" => node['kube']['images']['ddclient'],
            "env" => [
              {
                "name" => "CONFIG",
                "value" => ddclient_config
              }
            ]
          }
        ]
      }
    }
  }
}


configs = []
configs << deploy_config

node.default['kubernetes']['extra_configs']['ddclient'] = configs
