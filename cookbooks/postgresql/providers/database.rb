include ChefUtils::PostgreSQL::Connection
include ChefUtils::Password

action :create do
  unless exists?
    begin
      connection.exec("CREATE DATABASE #{new_resource.database} OWNER #{new_resource.owner}")
      Chef::Log.info "postgresql_database[#{new_resource.name}] created database #{new_resource.database}"
      new_resource.updated_by_last_action(true)
    ensure
      close
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::PostgresqlDatabase.new(@new_resource.name)

  begin
    query_result = connection.exec("select * from pg_database where datname = '#{@new_resource.database}';")
    if query_result.ntuples > 0
      existing_role_values = query_result.values[0]
      @current_resource.database(existing_role_values[0])
    end
  ensure
    close
  end

  @current_resource
end

private

def exists?
  begin
    query_result = connection.exec('select datname from pg_database;')
    databases = query_result.column_values(0)
    databases.include?(new_resource.database)
  ensure
    close
  end
end
