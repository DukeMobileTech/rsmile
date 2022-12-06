class AddSeedId < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :seed_id, :string
  end
end
