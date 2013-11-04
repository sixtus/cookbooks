default[:apple_id] = File.read("#{homedir}/.storerc").split.first rescue nil
default[:apple_password] = File.read("#{homedir}/.storerc").split.last rescue nil
default[:mac][:apps] = {}
