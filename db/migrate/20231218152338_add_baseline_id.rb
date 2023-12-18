class AddBaselineId < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :baseline_participant_id, :integer
  end
end
