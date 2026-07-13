class Rack::Attack
  # ------------------------------------------------------------------
  # Cache
  # ------------------------------------------------------------------
  if Rails.env.production?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
      url: ENV.fetch("REDIS_URL")
    )
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    # If you want to use Rails.cache (which is configured in config/environments/*.rb), uncomment the line below.
    # Rack::Attack.cache.store = Rails.cache
  end

  

  # ------------------------------------------------------------------
  # Safelist localhost
  # ------------------------------------------------------------------

  safelist("allow localhost") do |req|
    %w[127.0.0.1 ::1].include?(req.ip)
  end

  # ------------------------------------------------------------------
  # Health checks
  # ------------------------------------------------------------------

  safelist("health check") do |req|
    req.path == "/up"
  end

  # ------------------------------------------------------------------
  # General throttle
  # ------------------------------------------------------------------

  throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # ------------------------------------------------------------------
  # Login throttle
  # ------------------------------------------------------------------

  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.post? &&
       req.path == "/users/sign_in"
      req.ip
    end
  end

  # ------------------------------------------------------------------
  # Password reset
  # ------------------------------------------------------------------

  throttle("password-reset/ip", limit: 5, period: 1.minute) do |req|
    if req.post? &&
       req.path == "/users/password"
      req.ip
    end
  end

  # ------------------------------------------------------------------
  # API throttle
  # ------------------------------------------------------------------

  throttle("api/ip", limit: 1000, period: 1.hour) do |req|
    req.ip if req.path.start_with?("/api")
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]

  Rails.logger.warn(
    "[Rack::Attack] Throttled #{req.ip} #{req.request_method} #{req.path}"
  )
end

Rack::Attack.throttled_responder = lambda do |_request|
  [
    429,
    {
      "Content-Type" => "application/json",
      "Retry-After" => "60"
    },
    [
      {
        error: "Too many requests"
      }.to_json
    ]
  ]
end

