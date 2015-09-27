Ohai.plugin(:PrivateIpaddress) do
  provides "private_ipaddress"
  provides "private_hostname"

  depends "network"
  depends "hostname"

  collect_data(:default) do
    Ohai::Log.debug("looking for a private network interface in #{network.inspect}")

    ip = network['interfaces']
      .select { |name, i| name =~ /^(en|eth)/ }
      .map { |name, i| (i['addresses'] || {}).keys }
      .flatten
      .grep(/^10\.|^172\.1[6-9]\.|^172\.2\d\.|^172\.3[0-1]\.|^192\.168/)
      .first

    if ip
      private_ipaddress(ip)
      private_hostname("#{hostname}.local")
    end
  end
end
