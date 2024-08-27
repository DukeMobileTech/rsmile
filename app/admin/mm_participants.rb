# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Participant, as: 'MM Participants' do
  menu priority: 2, label: 'MM Participants'
  actions :all, except: %i[new destroy]
  permit_params :seed, :alternate_seed

  index do
    column :id do |participant|
      link_to participant.id, admin_participant_path(participant.id)
    end
    column :email
    column :phone_number, &:formatted_phone_number
    column :country
    column :self_generated_id
    column :code do |participant|
      link_to participant.code, admin_participant_path(participant.id)
    end
    column :sgm_group
    column 'Contact Method', &:contact_method
    column :seed
    column :alternate_seed
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :seed
      f.input :alternate_seed
    end
    f.actions
  end

  controller do
    def scoped_collection
      Participant.mm_participants
    end
  end
end
# rubocop:enable Metrics/BlockLength
