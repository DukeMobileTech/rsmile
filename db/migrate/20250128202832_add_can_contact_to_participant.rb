class AddCanContactToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :can_contact, :boolean, default: false
  end
end
