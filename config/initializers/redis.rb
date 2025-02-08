require 'redis'

# Redis client initialization
REDIS = Redis.new(url: "redis://localhost:6379/1")

REDIS.set("test_key", "Hello from Redis!")
puts REDIS.get("test_key")  
# You can also check if REDIS is initialized by running
Rails.logger.info "Redis Initialized: #{REDIS.inspect}"
