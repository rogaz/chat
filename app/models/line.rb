class Line < ActiveRecord::Base
  attr_accessible :room_id, :user_id, :text

  belongs_to :room
  belongs_to :user
end
