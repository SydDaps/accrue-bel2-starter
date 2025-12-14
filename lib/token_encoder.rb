class TokenEncoder
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY')

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  rescue JWT::ExpiredSignature => e
    Rails.logger.error "JWT Expired: #{e.message}"
    nil
  end
end
