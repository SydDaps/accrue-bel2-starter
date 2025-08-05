class User < ApplicationRecord
  include HasAccount

  has_secure_password

  validates :username, presence: true, uniqueness: true
end
