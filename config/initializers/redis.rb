$redis = Redis.new(url: ENV['REDIS_URL'] || ENV['HEROKU_REDIS_PUCE_URL'])
