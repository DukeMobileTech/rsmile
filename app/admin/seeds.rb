ActiveAdmin.register Participant, as: 'Seed' do
  menu label: 'RDS Seeds'
  menu priority: 2

  controller do
    def scoped_collection
      Participant.seeds
    end
  end
end
