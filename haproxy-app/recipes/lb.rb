include_recipe "haproxy::install_package"

haproxy 'lb' do
  config node['haproxy']['lb']
end
