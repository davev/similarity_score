
Sidekiq.configure_server do |config|
  config.redis = { url: (ENV['SIDEKIQ_REDIS_URL'] || ENV['REDIS_URL']), network_timeout: 10 }

  if defined?(ActiveRecord::Base)
    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = (ENV['DATABASE_REAPING_FREQUENCY'] || 10).to_i # seconds
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord in Sidekiq')
  end

end

Sidekiq.configure_client do |config|
  config.redis = { url: (ENV['SIDEKIQ_REDIS_URL'] || ENV['REDIS_URL']), network_timeout: 10 }
end
