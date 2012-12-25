require 'nagios'
require 'mysql'

class Nagios::Plugin::Mysql < Nagios::Plugin
  def initialize
    super
    @config.options.on('--database=DATABASE',
      '-dDATABASE', 'What database to use') {|database| @database = database}
  end

  protected

  def query(stmt)
    raise "No database selected" if @database.nil?

    [].tap do |ret|
      ::Mysql.init.tap do |dbh|
        dbh.options(::Mysql::READ_DEFAULT_FILE, "/var/nagios/home/.my.cnf")
        dbh.options(::Mysql::READ_DEFAULT_GROUP, "client")
        dbh.connect
        dbh.select_db(@database)

        dbh.query(stmt) do |result|
          result.each_hash do |row|
            ret << row
          end
        end

        dbh.close
      end
    end
  end
end
