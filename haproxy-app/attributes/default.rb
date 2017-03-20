node.default['haproxy']['lb'] = {
  :global => {
    :log => "127.0.0.1 local0",
    :maxconn => node['haproxy']['global_max_connections'],
    :user => node['haproxy']['user'],
    :group => node['haproxy']['group']
  },
  :defaults => {
    :log => "global",
    :retries => 2
  },
  :frontend => {
    :unifi => {
      :mode => "http",
      :bind => "0.0.0.0:8080",
      :default_backend => "unifi_nodes"
    },
    :unifi_ssl => {
      :mode => "tcp",
      :bind => "0.0.0.0:8443",
      :default_backend => "unifi_ssl_nodes"
    }
  },
  :backend => {
    :unifi_nodes => {
      :mode => "http",
      :server => [
        "unifi1 192.168.62.73:8080" => {
          :weight => 1
        }
      ]
    },
    :unifi_ssl_nodes => {
      :mode => "tcp",
      :server => [
        "unifi_ssl1 192.168.62.73:8443" => {
          :weight => 1
        }
      ]
    }
  }
}
