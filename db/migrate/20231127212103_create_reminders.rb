class CreateReminders < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :reminders do |t|
      t.integer :participant_id
      t.integer :category
      t.timestamps
    end
    create_table :email_logs do |t|
      t.string :recipient
      t.string :subject
      t.text :message
      t.timestamps
    end
  end
end
