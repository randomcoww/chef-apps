node.default['cql']['kea_leases']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['lan_subnet']).first

node.default['cql']['kea_leases']['cluster_name'] = "kea_leases"
node.default['cql']['kea_leases']['keyspace_name'] = 'keatest'
node.default['cql']['kea_leases']['datacenter'] = 'datacenter1'

node.default['cql']['kea_leases']['seeds'] = [
  node['environment_v2']['dhcp1_lan_ip'],
  node['environment_v2']['dhcp2_lan_ip']
]

node.default['cql']['kea_leases']['create_keyspace_query'] = %Q{CREATE KEYSPACE IF NOT EXISTS #{node['cql']['kea_leases']['keyspace_name']} WITH replication = { 'class': 'NetworkTopologyStrategy', '#{node['cql']['kea_leases']['datacenter']}': 3;}
node.default['cql']['kea_leases']['create_tables_query'] = [
  %Q{CREATE TABLE IF NOT EXISTS lease4 (
      address int,
      hwaddr blob,
      client_id blob,
      valid_lifetime bigint,
      expire bigint,
      subnet_id int,
      fqdn_fwd boolean,
      fqdn_rev boolean,
      hostname varchar,
      state int,
      PRIMARY KEY (address)
  );},
  %Q{CREATE INDEX IF NOT EXISTS lease4index1 ON lease4 (client_id);},
  %Q{CREATE INDEX IF NOT EXISTS lease4index2 ON lease4 (subnet_id);},
  %Q{CREATE INDEX IF NOT EXISTS lease4index3 ON lease4 (hwaddr);},
  %Q{CREATE INDEX IF NOT EXISTS lease4index4 ON lease4 (expire);},
  %Q{CREATE INDEX IF NOT EXISTS lease4index5 ON lease4 (state);},
  %Q{CREATE TABLE IF NOT EXISTS lease6 (
      address varchar,
      duid blob,
      valid_lifetime bigint,
      expire bigint,
      subnet_id int,
      pref_lifetime bigint,
      lease_type int,
      iaid int,
      prefix_len int,
      fqdn_fwd boolean,
      fqdn_rev boolean,
      hostname varchar,
      hwaddr blob,
      hwtype int,
      hwaddr_source int,
      state int,
      PRIMARY KEY (address)
  );},
  %Q{CREATE INDEX IF NOT EXISTS lease6index1 ON lease6 (lease_type);},
  %Q{CREATE INDEX IF NOT EXISTS lease6index2 ON lease6 (duid);},
  %Q{CREATE INDEX IF NOT EXISTS lease6index3 ON lease6 (iaid);},
  %Q{CREATE INDEX IF NOT EXISTS lease6index4 ON lease6 (subnet_id);},
  %Q{CREATE INDEX IF NOT EXISTS lease6index5 ON lease6 (expire);},
  %Q{CREATE INDEX IF NOT EXISTS lease6index6 ON lease6 (state);},
  %Q{CREATE TABLE IF NOT EXISTS lease6_types (
      lease_type int,
      name varchar,
      PRIMARY KEY (lease_type)
  );},
  %Q{INSERT INTO lease6_types (lease_type, name) VALUES (0, 'IA_NA');},
  %Q{INSERT INTO lease6_types (lease_type, name) VALUES (1, 'IA_TA');},
  %Q{INSERT INTO lease6_types (lease_type, name) VALUES (2, 'IA_PD');},
  %Q{CREATE TABLE IF NOT EXISTS lease_hwaddr_source (
      hwaddr_source int,
      name varchar,
      PRIMARY KEY (hwaddr_source)
  );},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (1, 'HWADDR_SOURCE_RAW');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (2, 'HWADDR_SOURCE_IPV6_LINK_LOCAL');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (4, 'HWADDR_SOURCE_DUID');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (8, 'HWADDR_SOURCE_CLIENT_ADDR_RELAY_OPTION');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (16, 'HWADDR_SOURCE_REMOTE_ID');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (32, 'HWADDR_SOURCE_SUBSCRIBER_ID');},
  %Q{INSERT INTO lease_hwaddr_source (hwaddr_source, name) VALUES (64, 'HWADDR_SOURCE_DOCSIS_CMTS');},
  %Q{CREATE TABLE IF NOT EXISTS dhcp4_options (
      option_id int,
      code int,
      value blob,
      formatted_value varchar,
      space varchar,
      persistent int,
      dhcp_client_class varchar,
      dhcp4_subnet_id int,
      host_id int,
      PRIMARY KEY (option_id)
  );},
  %Q{CREATE INDEX IF NOT EXISTS dhcp4_optionsindex1 ON dhcp4_options (host_id);},
  %Q{CREATE TABLE IF NOT EXISTS dhcp6_options (
      option_id int,
      code int,
      value blob,
      formatted_value varchar,
      space varchar,
      persistent int,
      dhcp_client_class varchar,
      dhcp6_subnet_id int,
      host_id int,
      PRIMARY KEY (option_id)
  );},
  %Q{CREATE INDEX IF NOT EXISTS dhcp6_optionsindex1 ON dhcp6_options (host_id);},
  %Q{CREATE TABLE IF NOT EXISTS lease_state (
      state int,
      name varchar,
      PRIMARY KEY (state)
  );},
  %Q{INSERT INTO lease_state (state, name) VALUES (0, 'default');},
  %Q{INSERT INTO lease_state (state, name) VALUES (1, 'declined');},
  %Q{INSERT INTO lease_state (state, name) VALUES (2, 'expired-reclaimed');},
  %Q{CREATE TABLE IF NOT EXISTS schema_version (
      version int,
      minor int,
      PRIMARY KEY (version)
  );},
  %Q{INSERT INTO schema_version (version, minor) VALUES (1, 0);}
]
