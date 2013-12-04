class User < ActiveRecord::Base
  attr_accessible :login, :name, :password, :password_confirmation

  has_many :messages
  has_and_belongs_to_many :rooms
  has_many :rooms_users

  after_create :create_chats
  #validates :login, :lenght => { :in => 4..15 }

  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::MD5
  end

  def create_chats
    (User.all - [self]).each do |user|
      users = [self, user]
      r = Room.create(:name => "sala_#{self.id}_#{user.id}", :created_automatically => true)
      r.users << users
    end
  end
end
