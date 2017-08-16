node.default['kubelet']['dhcp4_mysql']['lan_reservations'] = {}

node.default['kubelet']['dhcp4_mysql']['config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 3600,
    "renew-timer" => 3600,
    "rebind-timer" => 3600,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type" => "mysql",
      "name" => node['mysql_credentials']['kea']['database'],
      "host" => "127.0.0.1",
      "port" => "3306",
      "user" => node['mysql_credentials']['kea']['username'],
      "password" => node['mysql_credentials']['kea']['password'],
      "persist" => true
    },
    "subnet4" => [
      {
        "subnet" => node['environment_v2']['subnet']['lan'],
        "option-data" => [
          {
            "name" => "routers",
            "data" => node['environment_v2']['set']['gateway']['vip_lan']
          },
          {
            "name" => "domain-name-servers",
            "data" => [
              node['environment_v2']['set']['dns']['vip_lan'],
              '8.8.8.8'
            ].join(','),
            "csv-format" => true
          }
        ],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['lan_dhcp_pool']
          }
        ],
        "reservations" => node['kubelet']['dhcp4_mysql']['lan_reservations'].map { |k, v|
          {
            "hw-address" => k,
            "ip-address" => v
          }
        }
      },
      {
        "subnet" => node['environment_v2']['subnet']['vpn'],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['vpn_dhcp_pool']
          }
        ]
      }
    ],
    "dhcp-ddns" => {
      "enable-updates" => true,
      "qualifying-suffix" => "l.lan",
      "override-client-update" => true,
      "override-no-update" => true,
      "replace-client-name" => "when-not-present"
    }
  }
}

node.default['kubelet']['dhcp4_mysql']['sql'] = <<-EOF
--

CREATE DATABASE IF NOT EXISTS `#{node['mysql_credentials']['kea']['database']}`;
USE `#{node['mysql_credentials']['kea']['database']}`;

--
-- Table structure for table `lease6_types`
--

CREATE TABLE IF NOT EXISTS `lease6_types` (
  `lease_type` tinyint(4) NOT NULL,
  `name` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`lease_type`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `lease6_types`
--

LOCK TABLES `lease6_types` WRITE;

INSERT INTO `lease6_types`
  (lease_type,name)
VALUES
  (0,'IA_NA'),(1,'IA_TA'),(2,'IA_PD')
ON DUPLICATE KEY UPDATE
  lease_type = VALUES (lease_type),
  name = VALUES (name);

UNLOCK TABLES;

--
-- Table structure for table `lease_hwaddr_source`
--

CREATE TABLE IF NOT EXISTS `lease_hwaddr_source` (
  `hwaddr_source` int(10) unsigned NOT NULL,
  `name` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`hwaddr_source`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `lease_hwaddr_source`
--

LOCK TABLES `lease_hwaddr_source` WRITE;

INSERT INTO `lease_hwaddr_source`
  (hwaddr_source,name)
VALUES
  (0,'HWADDR_SOURCE_UNKNOWN'),(16,'HWADDR_SOURCE_REMOTE_ID'),(32,'HWADDR_SOURCE_SUBSCRIBER_ID'),(1,'HWADDR_SOURCE_RAW'),(64,'HWADDR_SOURCE_DOCSIS_CMTS'),(2,'HWADDR_SOURCE_IPV6_LINK_LOCAL'),(4,'HWADDR_SOURCE_DUID'),(8,'HWADDR_SOURCE_CLIENT_ADDR_RELAY_OPTION'),(128,'HWADDR_SOURCE_DOCSIS_MODEM')
ON DUPLICATE KEY UPDATE
  hwaddr_source = VALUES (hwaddr_source),
  name = VALUES (name);

UNLOCK TABLES;

--
-- Table structure for table `lease_state`
--

CREATE TABLE IF NOT EXISTS `lease_state` (
  `state` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`state`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `lease_state`
--

LOCK TABLES `lease_state` WRITE;

INSERT INTO `lease_state`
  (state,name)
VALUES
  (0,'default'),(1,'declined'),(2,'expired-reclaimed')
ON DUPLICATE KEY UPDATE
  state = VALUES (state),
  name = VALUES (name);

UNLOCK TABLES;

--
-- Table structure for table `schema_version`
--

CREATE TABLE IF NOT EXISTS `schema_version` (
  `version` int(11) NOT NULL,
  `minor` int(11) DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schema_version`
--

LOCK TABLES `schema_version` WRITE;

INSERT INTO `schema_version`
  (version,minor)
VALUES
  (5,1)
ON DUPLICATE KEY UPDATE
  version = VALUES (version),
  minor = VALUES (minor);

UNLOCK TABLES;

--
-- Table structure for table `dhcp_option_scope`
--

CREATE TABLE IF NOT EXISTS `dhcp_option_scope` (
  `scope_id` tinyint(3) unsigned NOT NULL,
  `scope_name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`scope_id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dhcp_option_scope`
--

LOCK TABLES `dhcp_option_scope` WRITE;

INSERT INTO `dhcp_option_scope`
  (scope_id,scope_name)
VALUES
  (0,'global'),(3,'host'),(1,'subnet'),(2,'client-class')
ON DUPLICATE KEY UPDATE
  scope_id = VALUES (scope_id),
  scope_name = VALUES (scope_name);

UNLOCK TABLES;

--
-- Table structure for table `host_identifier_type`
--

CREATE TABLE IF NOT EXISTS `host_identifier_type` (
  `type` tinyint(4) NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`type`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Dumping data for table `host_identifier_type`
--

LOCK TABLES `host_identifier_type` WRITE;

INSERT INTO `host_identifier_type`
  (type,name)
VALUES
  (0,'hw-address'),(3,'client-id'),(1,'duid'),(2,'circuit-id'),(4,'flex-id')
ON DUPLICATE KEY UPDATE
  type = VALUES (type),
  name = VALUES (name);

UNLOCK TABLES;

--
-- Table structure for table `hosts`
--

CREATE TABLE IF NOT EXISTS `hosts` (
  `host_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dhcp_identifier` varbinary(128) NOT NULL,
  `dhcp_identifier_type` tinyint(4) NOT NULL,
  `dhcp4_subnet_id` int(10) unsigned DEFAULT NULL,
  `dhcp6_subnet_id` int(10) unsigned DEFAULT NULL,
  `ipv4_address` int(10) unsigned DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `dhcp4_client_classes` varchar(255) DEFAULT NULL,
  `dhcp6_client_classes` varchar(255) DEFAULT NULL,
  `dhcp4_next_server` int(10) unsigned DEFAULT NULL,
  `dhcp4_server_hostname` varchar(64) DEFAULT NULL,
  `dhcp4_boot_file_name` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`host_id`),
  UNIQUE KEY `key_dhcp4_identifier_subnet_id` (`dhcp_identifier`,`dhcp_identifier_type`,`dhcp4_subnet_id`),
  UNIQUE KEY `key_dhcp6_identifier_subnet_id` (`dhcp_identifier`,`dhcp_identifier_type`,`dhcp6_subnet_id`),
  UNIQUE KEY `key_dhcp4_ipv4_address_subnet_id` (`ipv4_address`,`dhcp4_subnet_id`),
  KEY `fk_host_identifier_type` (`dhcp_identifier_type`),
  CONSTRAINT `fk_host_identifier_type` FOREIGN KEY (`dhcp_identifier_type`) REFERENCES `host_identifier_type` (`type`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Table structure for table `dhcp4_options`
--

CREATE TABLE IF NOT EXISTS `dhcp4_options` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` tinyint(3) unsigned NOT NULL,
  `value` blob,
  `formatted_value` text,
  `space` varchar(128) DEFAULT NULL,
  `persistent` tinyint(1) NOT NULL DEFAULT '0',
  `dhcp_client_class` varchar(128) DEFAULT NULL,
  `dhcp4_subnet_id` int(10) unsigned DEFAULT NULL,
  `host_id` int(10) unsigned DEFAULT NULL,
  `scope_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_id_UNIQUE` (`option_id`),
  KEY `fk_options_host1_idx` (`host_id`),
  KEY `fk_dhcp4_option_scope` (`scope_id`),
  CONSTRAINT `fk_options_host1` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`host_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dhcp4_option_scope` FOREIGN KEY (`scope_id`) REFERENCES `dhcp_option_scope` (`scope_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Table structure for table `dhcp6_options`
--

CREATE TABLE IF NOT EXISTS `dhcp6_options` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` smallint(5) unsigned NOT NULL,
  `value` blob,
  `formatted_value` text,
  `space` varchar(128) DEFAULT NULL,
  `persistent` tinyint(1) NOT NULL DEFAULT '0',
  `dhcp_client_class` varchar(128) DEFAULT NULL,
  `dhcp6_subnet_id` int(10) unsigned DEFAULT NULL,
  `host_id` int(10) unsigned DEFAULT NULL,
  `scope_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_id_UNIQUE` (`option_id`),
  KEY `fk_options_host1_idx` (`host_id`),
  KEY `fk_dhcp6_option_scope` (`scope_id`),
  CONSTRAINT `fk_options_host10` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`host_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dhcp6_option_scope` FOREIGN KEY (`scope_id`) REFERENCES `dhcp_option_scope` (`scope_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Table structure for table `ipv6_reservations`
--

CREATE TABLE IF NOT EXISTS `ipv6_reservations` (
  `reservation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(39) NOT NULL,
  `prefix_len` tinyint(3) unsigned NOT NULL DEFAULT '128',
  `type` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `dhcp6_iaid` int(10) unsigned DEFAULT NULL,
  `host_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`reservation_id`),
  UNIQUE KEY `key_dhcp6_address_prefix_len` (`address`,`prefix_len`),
  KEY `fk_ipv6_reservations_host_idx` (`host_id`),
  CONSTRAINT `fk_ipv6_reservations_Host` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`host_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Table structure for table `lease4`
--

CREATE TABLE IF NOT EXISTS `lease4` (
  `address` int(10) unsigned NOT NULL,
  `hwaddr` varbinary(20) DEFAULT NULL,
  `client_id` varbinary(128) DEFAULT NULL,
  `valid_lifetime` int(10) unsigned DEFAULT NULL,
  `expire` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `subnet_id` int(10) unsigned DEFAULT NULL,
  `fqdn_fwd` tinyint(1) DEFAULT NULL,
  `fqdn_rev` tinyint(1) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `state` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`address`),
  KEY `lease4_by_hwaddr_subnet_id` (`hwaddr`,`subnet_id`),
  KEY `lease4_by_client_id_subnet_id` (`client_id`,`subnet_id`),
  KEY `lease4_by_state_expire` (`state`,`expire`),
  CONSTRAINT `fk_lease4_state` FOREIGN KEY (`state`) REFERENCES `lease_state` (`state`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
-- Table structure for table `lease6`
--

CREATE TABLE IF NOT EXISTS `lease6` (
  `address` varchar(39) NOT NULL,
  `duid` varbinary(128) DEFAULT NULL,
  `valid_lifetime` int(10) unsigned DEFAULT NULL,
  `expire` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `subnet_id` int(10) unsigned DEFAULT NULL,
  `pref_lifetime` int(10) unsigned DEFAULT NULL,
  `lease_type` tinyint(4) DEFAULT NULL,
  `iaid` int(10) unsigned DEFAULT NULL,
  `prefix_len` tinyint(3) unsigned DEFAULT NULL,
  `fqdn_fwd` tinyint(1) DEFAULT NULL,
  `fqdn_rev` tinyint(1) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `hwaddr` varbinary(20) DEFAULT NULL,
  `hwtype` smallint(5) unsigned DEFAULT NULL,
  `hwaddr_source` int(10) unsigned DEFAULT NULL,
  `state` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`address`),
  KEY `lease6_by_iaid_subnet_id_duid` (`iaid`,`subnet_id`,`duid`),
  KEY `lease6_by_state_expire` (`state`,`expire`),
  KEY `fk_lease6_type` (`lease_type`),
  KEY `fk_lease6_hwaddr_source` (`hwaddr_source`),
  CONSTRAINT `fk_lease6_state` FOREIGN KEY (`state`) REFERENCES `lease_state` (`state`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_lease6_type` FOREIGN KEY (`lease_type`) REFERENCES `lease6_types` (`lease_type`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_lease6_hwaddr_source` FOREIGN KEY (`hwaddr_source`) REFERENCES `lease_hwaddr_source` (`hwaddr_source`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

--
EOF
