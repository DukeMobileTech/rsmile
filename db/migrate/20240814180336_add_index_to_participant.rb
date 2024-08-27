class AddIndexToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_index :participants, :baseline_participant_id
    add_column :participants, :alternate_seed, :boolean, default: false
  end
end
