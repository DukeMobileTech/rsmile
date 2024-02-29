class AddDueOnToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :due_on, :datetime
    add_column :participants, :derived_seed, :boolean, default: false
    add_column :participants, :chain_level, :integer, default: 0
  end
end
