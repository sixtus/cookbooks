default[:apple_id] = File.read("#{homedir}/.storerc").split.first
default[:apple_password] = File.read("#{homedir}/.storerc").split.last
default[:mac][:apps] = {}
