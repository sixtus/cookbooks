define :duply_backup,
  :source => nil,
  :max_full_backups => 3,
  :max_full_age => "1M",
  :volume_size => "25M" do
  node.set[:backup][:configs][params[:name]] = params
end
