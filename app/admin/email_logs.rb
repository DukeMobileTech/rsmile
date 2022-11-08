ActiveAdmin.register EmailLog do
  index do
    column :id
    column :recipient
    column :subject
    column :message do |log| raw(log.message) end
  end
end
