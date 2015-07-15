require 'pushpop'
require 'pushpop-keen'

MAX_AGE = 4.hours # Can change this to whatever you want

job 'Warm up keen cached queries' do

  every (MAX_AGE + 2) # We give a 2 second allowance to let the cache expire

  keen 'run query' do
    event_collection    'pageviews'
    analysis_type       'count'
    timeframe           'last_24_hours'
    group_by            'url'
    max_age             MAX_AGE
  end

end
