class AddSeedIdToParticipantsIndex < ActiveRecord::Migration[6.1]
  def change
    add_index(:participants, :seed_id)
  end
end
