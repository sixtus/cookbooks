define :php_fpm_pool do
  node.set[:php][:fpm][:pools][params[:name].to_sym] = params
  include_recipe "php"
end
