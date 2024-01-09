class AddTypeToReminder < ActiveRecord::Migration[6.1]
  def change
    add_column :reminders, :channel, :string
    change_column :reminders, :category, :string
  end
end
