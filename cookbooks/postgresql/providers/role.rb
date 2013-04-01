include ChefUtils::PostgreSQL::Connection
include ChefUtils::Password

action :create do
  action = ''
  command = ''

  unless exists?
    command += "CREATE ROLE #{new_resource.role}"
    action = "created"
  else
    command += "ALTER ROLE #{new_resource.role}"
    action = "altered"
  end

  command += " PASSWORD '#{new_resource.password}'" if new_resource.password
  command += " SUPERUSER" if new_resource.superuser
  command += " INHERIT" if new_resource.inherit
  command += " CREATEROLE" if new_resource.createrole
  command += " CREATEDB" if new_resource.createdb
  command += " LOGIN" if new_resource.login

  begin
    connection.exec(command)
    Chef::Log.info "postgresql_role[#{new_resource.name}] #{action} role #{new_resource.role}"
    new_resource.updated_by_last_action(true)
  ensure
    close
  end
end

def load_current_resource
  @current_resource = Chef::Resource::PostgresqlRole.new(@new_resource.name)

  begin
    query_result = connection.exec("select * from pg_roles where rolname = '#{@new_resource.role}';")
    if query_result.ntuples > 0
      existing_role_values = query_result.values[0]
      @current_resource.role(existing_role_values[0])
      @current_resource.superuser(bool_convert existing_role_values[1])
      @current_resource.inherit(bool_convert existing_role_values[2])
      @current_resource.createrole(bool_convert existing_role_values[3])
      @current_resource.createdb(bool_convert existing_role_values[4])
      @current_resource.login(bool_convert existing_role_values[6])
    end
  ensure
    close
  end

  @current_resource
end

private

def exists?
  begin
    query_result = connection.exec('select rolname from pg_roles;')
    roles = query_result.column_values(0)
    roles.include?(new_resource.role)
  ensure
    close
  end
end

def bool_convert(db_bool_value)
  case db_bool_value
  when 'f'
    false
  when 't'
    true
  end
end
