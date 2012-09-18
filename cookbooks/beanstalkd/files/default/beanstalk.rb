require 'beanstalk-client'

collect do
  beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
  stats = beanstalk.stats_tube('default')
  sampler.emit(:gauge, 'beanstalk.jobs.urgent', stats['current-jobs-urgent'])
  sampler.emit(:gauge, 'beanstalk.jobs.ready', stats['current-jobs-ready'])
  sampler.emit(:gauge, 'beanstalk.jobs.reserved', stats['current-jobs-reserved'])
  sampler.emit(:gauge, 'beanstalk.jobs.delayed', stats['current-jobs-delayed'])
  sampler.emit(:gauge, 'beanstalk.jobs.burried', stats['current-jobs-buried'])
  sampler.emit(:derive, 'beanstalk.jobs', stats['total-jobs'])
end
