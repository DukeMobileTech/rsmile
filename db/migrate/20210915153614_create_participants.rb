class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants do |t|
      t.string :email
      t.string :phone_number
      t.string :country
      t.string :self_generated_id
      t.string :study_id
      t.string :rds_id
      t.string :code
      t.string :referrer_code
      t.string :sgm_group
      t.string :referrer_sgm_group
      t.boolean :match
      t.integer :quota
      t.timestamps
    end

    create_table :survey_responses do |t|
      t.integer :participant_id
      t.string :survey_uuid
      t.string :response_uuid
      t.boolean :survey_complete
      t.timestamps
    end

    create_table :users do |t|
      t.string :email, null: false
      t.timestamps
    end

    create_table :api_keys do |t|
      t.integer :bearer_id, null: false
      t.string :bearer_type, null: false
      t.string :token_digest, null: false
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :participants, :code, unique: true
    add_index :participants, :email, unique: true
    add_index :api_keys, [:bearer_id, :bearer_type]
    add_index :api_keys, :token_digest, unique: true
  end
end
