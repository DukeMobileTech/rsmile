class AddRaffleCounter < ActiveRecord::Migration[6.1]
  def change
    rename_column :participants, :quota, :raffles_count
    Participant.find_each do |participant|
      Participant.reset_counters(participant.id, :raffles)
    end
  end
end
