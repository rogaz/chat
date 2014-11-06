class Room < ActiveRecord::Base
  attr_accessible :name, :created_automatically

  has_many :lines, :dependent => :destroy
  has_and_belongs_to_many :users
  has_many :rooms_users, dependent: :destroy


  def users_to_user
    self.users - current_user
  end


  def users_to_add
    #User.includes(:rooms_users).select('"users".*').where(:rooms_users => {:user_id => nil, :room_id => self.id})
    #User.all(:include => :rooms_users, :conditions => {:rooms_users => {:user_id => nil, :room_id => self.id}})
  end
end
