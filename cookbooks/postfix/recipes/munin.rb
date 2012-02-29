if tagged?("munin-node")
  munin_plugin "postfix_mailstats" do
    source "postfix_mailstats"
    config ["user root", "group wheel", "env.logfile mail.log"]
  end

  %w(mailqueue mailvolume).each do |p|
    munin_plugin "postfix_#{p}" do
      config ["user root", "group wheel", "env.logfile mail.log"]
    end
  end
end
