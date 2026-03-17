class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base
  EXPIRATION = 24.hours.from_now

  def self.encode(payload, exp = EXPIRATION)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    raise JWT::ExpiredSignature, "Token has expired"
  rescue JWT::DecodeError
    raise JWT::DecodeError, "Invalid token"
  end
end
