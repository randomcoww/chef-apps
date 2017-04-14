node.default['cql']['kea_leases']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['lan_subnet']).first

cluster_name = "kea_leases"
node.default['cql']['kea_leases']['cluster_name'] = cluster_name
node.default['cql']['kea_leases']['keyspace_name'] = 'keatest'

node.default['cql']['kea_leases']['hints_directory'] = "/var/lib/cassandra/#{cluster_name}/hints"
node.default['cql']['kea_leases']['saved_caches_directory'] = "/var/lib/cassandra/#{cluster_name}/saved_caches"
node.default['cql']['kea_leases']['commitlog_directory'] = "/var/lib/cassandra/#{cluster_name}/commitlog"
node.default['cql']['kea_leases']['data_file_directory'] = "/var/lib/cassandra/#{cluster_name}/data"
node.default['cql']['kea_leases']['seeds'] = [
  node['environment_v2']['dhcp1_lan_ip'],
  node['environment_v2']['dhcp2_lan_ip']
]

node.default['cql']['kea_leases']['create_tables_cql'] = 'https://raw.githubusercontent.com/isc-projects/kea/master/src/share/database/scripts/cql/dhcpdb_create.cql'
node.default['cql']['kea_leases']['create_tables_cql_path'] = ::File.join(Chef::Config[:file_cache_path], 'kea_leases_create_tables_cql')

node.default['cql']['kea_leases']['create_keyspace_query'] = %Q{CREATE KEYSPACE IF NOT EXISTS #{node['cql']['kea_leases']['keyspace_name']} WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': #{node['cql']['kea_leases']['seeds'].length} };}
node.default['cql']['kea_leases']['create_tables_query'] = %Q{SOURCE #{node['cql']['kea_leases']['create_tables_cql_path']};}

node.default['cql']['kea_leases']['cassandra_config'] = {
  "cluster_name" => node['cql']['kea_leases']['cluster_name'].to_s,
  "num_tokens" => 256,
  "hinted_handoff_enabled" => true,
  "max_hint_window_in_ms" => 10800000,
  "hinted_handoff_throttle_in_kb" => 1024,
  "max_hints_delivery_threads" => 2,
  "hints_directory" => node['cql']['kea_leases']['hints_directory'].to_s,
  "hints_flush_period_in_ms" => 10000,
  "max_hints_file_size_in_mb" => 128,
  "batchlog_replay_throttle_in_kb" => 1024,
  "authenticator" => "AllowAllAuthenticator",
  "authorizer" => "AllowAllAuthorizer",
  "role_manager" => "CassandraRoleManager",
  "roles_validity_in_ms" => 2000,
  "permissions_validity_in_ms" => 2000,
  "credentials_validity_in_ms" => 2000,
  "partitioner" => "org.apache.cassandra.dht.Murmur3Partitioner",
  "data_file_directories" => [
    node['cql']['kea_leases']['data_file_directory'].to_s
  ],
  "commitlog_directory" => node['cql']['kea_leases']['commitlog_directory'].to_s,
  "cdc_enabled" => false,
  "disk_failure_policy" => "stop",
  "commit_failure_policy" => "stop",
  "prepared_statements_cache_size_mb" => nil,
  "thrift_prepared_statements_cache_size_mb" => nil,
  "key_cache_size_in_mb" => nil,
  "key_cache_save_period" => 14400,
  "row_cache_size_in_mb" => 0,
  "row_cache_save_period" => 0,
  "counter_cache_size_in_mb" => nil,
  "counter_cache_save_period" => 7200,
  "saved_caches_directory" => node['cql']['kea_leases']['saved_caches_directory'].to_s,
  "commitlog_sync" => "periodic",
  "commitlog_sync_period_in_ms" => 10000,
  "commitlog_segment_size_in_mb" => 32,
  "seed_provider" => [
    {
      "class_name" => "org.apache.cassandra.locator.SimpleSeedProvider",
      "parameters" => [
        {
          "seeds" => node['cql']['kea_leases']['seeds'].to_a.join(',')
        }
      ]
    }
  ],
  "concurrent_reads" => 32,
  "concurrent_writes" => 32,
  "concurrent_counter_writes" => 32,
  "concurrent_materialized_view_writes" => 32,
  "memtable_allocation_type" => "heap_buffers",
  "index_summary_capacity_in_mb" => nil,
  "index_summary_resize_interval_in_minutes" => 60,
  "trickle_fsync" => false,
  "trickle_fsync_interval_in_kb" => 10240,
  "storage_port" => 7000,
  "ssl_storage_port" => 7001,
  "listen_address" => node['cql']['kea_leases']['node_ip'],
  "start_native_transport" => true,
  "native_transport_port" => 9042,
  "start_rpc" => false,
  "rpc_address" => "localhost",
  "rpc_port" => 9160,
  "rpc_keepalive" => true,
  "rpc_server_type" => "sync",
  "thrift_framed_transport_size_in_mb" => 15,
  "incremental_backups" => false,
  "snapshot_before_compaction" => false,
  "auto_snapshot" => true,
  "column_index_size_in_kb" => 64,
  "column_index_cache_size_in_kb" => 2,
  "compaction_throughput_mb_per_sec" => 16,
  "sstable_preemptive_open_interval_in_mb" => 50,
  "read_request_timeout_in_ms" => 5000,
  "range_request_timeout_in_ms" => 10000,
  "write_request_timeout_in_ms" => 2000,
  "counter_write_request_timeout_in_ms" => 5000,
  "cas_contention_timeout_in_ms" => 1000,
  "truncate_request_timeout_in_ms" => 60000,
  "request_timeout_in_ms" => 10000,
  "slow_query_log_timeout_in_ms" => 500,
  "cross_node_timeout" => false,
  "endpoint_snitch" => "SimpleSnitch",
  "dynamic_snitch_update_interval_in_ms" => 100,
  "dynamic_snitch_reset_interval_in_ms" => 600000,
  "dynamic_snitch_badness_threshold" => 0.1,
  "request_scheduler" => "org.apache.cassandra.scheduler.NoScheduler",
  "server_encryption_options" => {
    "internode_encryption" => "none",
    "keystore" => "conf/.keystore",
    "keystore_password" => "cassandra",
    "truststore" => "conf/.truststore",
    "truststore_password" => "cassandra"
  },
  "client_encryption_options" => {
    "enabled" => false,
    "optional" => false,
    "keystore" => "conf/.keystore",
    "keystore_password" => "cassandra"
  },
  "internode_compression" => "dc",
  "inter_dc_tcp_nodelay" => false,
  "tracetype_query_ttl" => 86400,
  "tracetype_repair_ttl" => 604800,
  "enable_user_defined_functions" => false,
  "enable_scripted_user_defined_functions" => false,
  "windows_timer_interval" => 1,
  "transparent_data_encryption_options" => {
    "enabled" => false,
    "chunk_length_kb" => 64,
    "cipher" => "AES/CBC/PKCS5Padding",
    "key_alias" => "testing:1",
    "key_provider" => [
      {
        "class_name" => "org.apache.cassandra.security.JKSKeyProvider",
        "parameters" => [
          {
            "keystore" => "conf/.keystore",
            "keystore_password" => "cassandra",
            "store_type" => "JCEKS",
            "key_password" => "cassandra"
          }
        ]
      }
    ]
  },
  "tombstone_warn_threshold" => 1000,
  "tombstone_failure_threshold" => 100000,
  "batch_size_warn_threshold_in_kb" => 5,
  "batch_size_fail_threshold_in_kb" => 50,
  "unlogged_batch_across_partitions_warn_threshold" => 10,
  "compaction_large_partition_warning_threshold_mb" => 100,
  "gc_warn_threshold_in_ms" => 1000,
  "back_pressure_enabled" => false,
  "back_pressure_strategy" => [
    {
      "class_name" => "org.apache.cassandra.net.RateBasedBackPressure",
      "parameters" => [
        {
          "high_ratio" => 0.9,
          "factor" => 5,
          "flow" => "FAST"
        }
      ]
    }
  ]
}
