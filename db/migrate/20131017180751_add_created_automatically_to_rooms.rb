class AddCreatedAutomaticallyToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :created_automatically, :boolean
  end
end
