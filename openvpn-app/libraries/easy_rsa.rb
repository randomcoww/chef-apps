module EasyRsaHelper

  def ca_crt
    @ca_crt ||= easy_rsa.generate_ca_cert
  end

  def dh
    @dh ||= easy_rsa.generate_dh
  end

  def server_csr
    @server_csr ||= server_certs['csr']
  end

  def server_crt
    @server_crt ||= server_certs['crt']
  end


  private

  def easy_rsa
    @easy_rsa ||= EasyRsa.new(node['openvpn']['server']['label'],
      node['openvpn']['server']['easy_rsa']['data_bag'],
      node['openvpn']['server']['easy_rsa']['data_bag_item'],
      node['openvpn']['server']['easy_rsa']['cert_variables']
    )
  end

  def server_certs
    @server_certs ||= easy_rsa.generate_client_cert(node['openvpn']['server']['label'])
  end
end
