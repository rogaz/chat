class CreateRoomsUsers < ActiveRecord::Migration
  def change
    create_table :rooms_users, :id => false do |t|
      t.integer :room_id
      t.integer :user_id
    end
  end
end
