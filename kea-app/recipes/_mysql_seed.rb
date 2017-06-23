directory ::File.dirname(node['kea']['dhcp4_mysql']['create_tables_sql_file']) do
  recursive true
end

remote_file node['kea']['dhcp4_mysql']['create_tables_sql_file'] do
  source node['kea']['dhcp4_mysql']['create_tables_sql_source']
  action :create_if_missing
  notifies :query, "mysql_cluster_sql[create_tables]", :immediately
end

mysql_cluster_sql 'create_tables' do
  queries lazy {
    lines = []
      ::File.read(node['kea']['dhcp4_mysql']['create_tables_sql_file']).each_line do |e|
        ## remove comments
        e.gsub!(/\s*#.*?$/, '')
        e.gsub!(/\s*--.*?$/, '')

        e.chomp!
        e.strip!
        next if e.empty?

        e.gsub!('INNODB', 'NDBCLUSTER')
        lines << e
      end

      lines.join(' ').split(';')
    }
  timeout 120
  ignore_errors true
  options ({
    username: node['mysql_credentials']['kea']['username'],
    password: node['mysql_credentials']['kea']['password'],
    database: node['mysql_credentials']['kea']['database'],
    host: '127.0.0.1',
    port: 3306
  })
  action :nothing
end
