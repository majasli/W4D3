class User < ApplicationRecord

  validates :user_name, :session_token, presence: true, uniqueness: true
  validates :password_digest, presence: { message: 'Password can\'t be blank' }
  validates :password, length: { minimum: 6, allow_nil: true }
  after_initialize :ensure_session_token

  attr_reader :password

  has_many :cats,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: "Cat"

  has_many :cat_requests,
    class_name: "CatRentalRequest",
    foreign_key: :user_id,
    primary_key: :id 

  def self.find_by_credentials(user_name, password)
    user = User.find_by(user_name: user_name)
    return user if user && user.is_password?(password)
  end

  def self.generate_session_token
    SecureRandom::urlsafe_base64(16)
  end

  def is_password?(password)
    bc_pw = BCrypt::Password.new(self.password_digest)
    bc_pw.is_password?(password)
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end


  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save!
    self.session_token
  end

  private
  def ensure_session_token
    self.session_token ||= User.generate_session_token
  end


end
