require 'beanstalk-client'

collect do
  beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
  beanstalk.list_tubes.values.flatten.uniq.each do |tube|
    stats = beanstalk.stats_tube(tube)
    Metriks.histogram("beanstalk.#{tube}.jobs:urgent").update(stats['current-jobs-urgent'])
    Metriks.histogram("beanstalk.#{tube}.jobs:ready").update(stats['current-jobs-ready'])
    Metriks.histogram("beanstalk.#{tube}.jobs:reserved").update(stats['current-jobs-reserved'])
    Metriks.histogram("beanstalk.#{tube}.jobs:delayed").update(stats['current-jobs-delayed'])
    Metriks.histogram("beanstalk.#{tube}.jobs:burried").update(stats['current-jobs-buried'])
    Metriks.derive("beanstalk.#{tube}.jobs").mark(stats['total-jobs'])
  end
end
