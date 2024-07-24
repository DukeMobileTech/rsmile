ActiveAdmin.register Reminder do
  belongs_to :participant

  index do
    id_column
    column :participant
    column :category
    column :channel
    column :message do |reminder|
      # rubocop:disable Rails/OutputSafety
      raw(reminder.message)
      # rubocop:enable Rails/OutputSafety
    end
    column :created_at
    column :updated_at
    actions
  end
end
