class AddSeedToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :seed, :boolean, default: false
    add_column :participants, :remind, :boolean, default: true
    add_column :participants, :quota_met, :boolean, default: false
    remove_column :participants, :resume_code, :string
  end
end
