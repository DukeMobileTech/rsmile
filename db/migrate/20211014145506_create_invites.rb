class CreateInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :invites do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :invite_code, limit: 40
      t.datetime :invited_at
      t.datetime :redeemed_at
      t.timestamps
    end
    add_index :invites, [:id, :email], unique: true
    add_index :invites, [:id, :invite_code], unique: true
  end
end
