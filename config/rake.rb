# Configure the Rakefile's tasks.

# The company name - used for SSL certificates, and in srvious other places
COMPANY_NAME = "Example Com"

# The Country Name to use for SSL Certificates
SSL_COUNTRY_NAME = "DE"

# The State Name to use for SSL Certificates
SSL_STATE_NAME = "Berlin"

# The Locality Name for SSL - typically, the city
SSL_LOCALITY_NAME = "Berlin"

# What department?
SSL_ORGANIZATIONAL_UNIT_NAME = "Operations"

# The SSL contact email address
SSL_EMAIL_ADDRESS = "hostmaster@example.com"

# The upstream branch to track
UPSTREAM_BRANCH="next"

# make rake more silent
RakeFileUtils.verbose_flag = false
Chef::Log.level = :error

# The top of the repository checkout
TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), ".."))

# chef config files
if Process.euid > 0
  KNIFE_CONFIG_FILE = File.expand_path(File.join(TOPDIR, ".chef", "knife.rb"))
  CLIENT_KEY_FILE = File.expand_path(File.join(TOPDIR, ".chef", "client.pem"))
else
  KNIFE_CONFIG_FILE = "/root/.chef/knife.rb"
  CLIENT_KEY_FILE = "/root/.chef/client.pem"
end

# directories for entities
BAGS_DIR = File.expand_path(File.join(TOPDIR, "databags"))
COOKBOOKS_DIR = File.expand_path(File.join(TOPDIR, "cookbooks"))
NODES_DIR = File.expand_path(File.join(TOPDIR, "nodes"))
ROLES_DIR = File.expand_path(File.join(TOPDIR, "roles"))
ENVIRONMENTS_DIR = File.expand_path(File.join(TOPDIR, "environments"))
SITE_COOKBOOKS_DIR = File.expand_path(File.join(TOPDIR, "site-cookbooks"))
TEMPLATES_DIR = File.expand_path(File.join(TOPDIR, "tasks", "templates"))

# documentation directories
DOC_DIR = File.expand_path(File.join(TOPDIR, "documentation"))
DOC_SOURCE_DIR = File.expand_path(File.join(DOC_DIR, "source"))
DOC_BUILD_DIR = File.expand_path(File.join(TOPDIR, "cookbooks", "chef", "files", "default", "documentation", "html"))

# Directories needed by the SSL tasks
SSL_CA_DIR = File.expand_path(File.join(TOPDIR, "ca"))
SSL_CERT_DIR = File.expand_path(File.join(TOPDIR, "cookbooks/openssl/files/default/certificates"))

# OpenSSL config file
SSL_CONFIG_FILE = File.expand_path(File.join(TOPDIR, "config", "openssl.cnf"))

# chef-solo only platforms
CHEF_SOLO_PLATFORMS = %w(
  mac_os_x
)
