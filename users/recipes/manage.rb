data_bag = Chef::EncryptedDataBagItem.load(node['user_manager']['data_bag'], node['user_manager']['data_bag_item'])

node['user_manager']['instances'].each do |name, c|
  data_bag_user = data_bag[name]

  next unless data_bag_user.is_a?(Hash)
  Chef::Log.info("Create user: #{data_bag_user['username']}")

  user data_bag_user['username'] do
    uid data_bag_user['uid'] unless data_bag_user['uid'].nil?
    home data_bag_user['home'] unless data_bag_user['home'].nil?
    manage_home true
    shell data_bag_user['shell'] unless data_bag_user['shell'].nil?
    password data_bag_user['password_shadow'] unless data_bag_user['password_shadow'].nil?
    action c['enabled'] ? :create : :remove
  end

  if data_bag_user['ssh_authorized_keys'].is_a?(Array)
    authorized_keys_file = ::File.join(data_bag_user['home'], '.ssh', 'authorized_keys')

    directory ::File.dirname(authorized_keys_file) do
      recursive true
      owner data_bag_user['username']
      group data_bag_user['username']
      action :create_if_missing
    end

    ## add ssh keys to user if porvided
    file authorized_keys_file do
      content data_bag_user['ssh_authorized_keys'].join($/)
      owner data_bag_user['username']
      group data_bag_user['username']
      mode '0644'
      action :create
    end
  end
end
