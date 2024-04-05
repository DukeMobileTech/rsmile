ActiveAdmin.register EmailLog do
  index do
    column :id
    column :recipient
    column :subject
    column :message do |log|
      # rubocop:disable Rails/OutputSafety
      raw(log.message)
      # rubocop:enable Rails/OutputSafety
    end
    column :created_at
    column :updated_at
    actions
  end
end
