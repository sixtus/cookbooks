package "dev-db/postgresql" do
  version ":9.4"
end

chef_gem 'pg' do
  action :install
  compile_time true
end
