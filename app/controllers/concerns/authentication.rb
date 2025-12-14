module Authentication
  extend ActiveSupport::Concern

  def current_user
    @current_user ||= authenticate_user
  end

  private

  def authenticate_user
    token = fetch_token
    return nil unless token

    decoded_token = TokenEncoder.decode(token)
    return nil unless decoded_token

    user_id = decoded_token[:user_id]
    User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def fetch_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    prefix, token = auth_header.split(' ')
    token
  end
end
