class AddAlternatePhoneNumberToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :alternate_phone_number, :string, null: true
    add_index :participants, :alternate_phone_number
  end
end
