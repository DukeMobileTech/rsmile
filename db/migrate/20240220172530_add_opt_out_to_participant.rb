class AddOptOutToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :opt_out, :boolean, default: false
  end
end
