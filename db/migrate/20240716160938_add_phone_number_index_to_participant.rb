class AddPhoneNumberIndexToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_index :participants, :phone_number, unique: true
  end
end
