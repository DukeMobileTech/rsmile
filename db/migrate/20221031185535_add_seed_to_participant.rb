class AddSeedToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :seed, :boolean, default: false
    add_column :participants, :remind, :boolean, default: true
    add_column :participants, :enter_raffle, :boolean, default: true
    add_column :participants, :raffle_quota_met, :boolean, default: false
    create_table :raffles do |t|
      t.integer :participant_id
      t.boolean :completion_entry, default: false
      t.boolean :recruitment_entry, default: true
      t.string :recruitee_code
      t.string :response_uuid
      t.timestamps
    end
    add_index :raffles, %i[participant_id recruitee_code], unique: true
    add_index :raffles, %i[participant_id response_uuid], unique: true
    add_index :survey_responses, :participant_id
  end
end
