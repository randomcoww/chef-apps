node.default['kubernetes']['kube_scheduler']['args'] = [
  "/hyperkube",
  "scheduler",
  "--master=http://127.0.0.1:8080",
  "--leader-elect=true",
]
