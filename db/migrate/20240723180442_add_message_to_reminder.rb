class AddMessageToReminder < ActiveRecord::Migration[6.1]
  def change
    add_column :reminders, :message, :text
  end
end
