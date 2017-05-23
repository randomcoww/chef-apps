node.default['kubernetes']['kube_proxy']['args'] = [
  "/hyperkube",
  "proxy",
  "--master=http://127.0.0.1:8080"
]
