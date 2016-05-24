default[:gobblin][:git][:repository] = "https://github.com/liquidm/gobblin"
default[:gobblin][:git][:revision] = "production"

default[:gobblin][:topics] = %w{
  ep.eu2/metrics
  ep.eu2/tracking_results
  ed.eu2/ed_bid_requests
  ed.eu2/ed_reports
  ep.us2/metrics
  ep.us2/tracking_results
  ed.us2/ed_bid_requests
  ed.us2/ed_reports
}
