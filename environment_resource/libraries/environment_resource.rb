module EnvironmentResource

  # {
  #   'environment_resource' => {
  #     'subnet' => '192.168.62.0/23',
  #     'data_bag' => 'environment_resource',
  #     'data_bag_item' => 'test',
  #     'key1' => [
  #       'value1',
  #       'value2'
  #     ]
  #   }
  # }


  class Ip
    def initialize(node)
      @vars = node['environment_resource']
    end

    def get(key)
      @vars[key].each do |ip|
        next if host_up?(ip)
        return ip
      end
    end


    private

    def host_up?(ip)
      # check = Net::Ping::External.new(ip)
      # check.ping?
      system("ping #{ip} -c 3")
      return $?.success?
    end
  end


  class Data
    require 'socket'
    require 'ipaddr'

    include Dbag
    attr_accessor :subnet_ips

    def initialize(node)
      @vars = node['environment_resource'].dup

      @keystore = Dbag::Keystore.new(
        @vars['data_bag'],
        @vars['data_bag_item']
      )

      subnet = IPAddr.new(@vars['subnet'])
      @subnet_ips = []
      Socket.ip_address_list.each do |e|
        if e.ipv4_private?
          if subnet.include?(e.ip_address)
            @subnet_ips << e.ip_address
          end
        end
      end
    end

    def get_and_set(key)
      resource = get(key)

      if resource.nil?
        resource = find_new(key, @vars[key])
        set(key, resource)
      end
      return resource
    end

    def get(key)
      subnet_ips.each do |ip|
        dbag = @keystore.get(ip)
        if dbag.has_key?(key)
          return dbag[key]
        end
      end
    end

    def delete
      subnet_ips.each do |ip|
        @keystore.delete(ip)
      end
    end


    private

    def find_new(key, resources)
      # resources = ['value1', 'value2']
      @keystore.data_bag.each do |ip, registered|
        if !host_up?(ip)
          @keystore.delete(ip)
          next
        end
        Chef::Log.info("Host response from #{ip}")

        # registered = {
        next unless registered.has_key?(key)
        #   'type1' => 'value1'
        #   'type2' => 'value2'
        # }
        resources.delete(registered[key])
        Chef::Log.info("#{registered[key]} used by #{ip}")
      end
      Chef::Log.info("Remaining resource #{resources}, returning #{resources.first}")

      return resources.first
    end

    def set(key, resource)
      subnet_ips.each do |ip|
        keystore = @keystore.get(ip) || {}
        keystore.merge!(
          key => resource
        )
        @keystore.put(ip, keystore)
      end
    end

    def host_up?(ip)
      # check = Net::Ping::External.new(ip)
      # check.ping?
      system("ping #{ip} -c 1")
      return $?.success?
    end
  end
end
