# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Participant, as: 'Alternate Seed' do
  menu priority: 4, label: 'RDS Alt Seeds'
  actions :all, except: %i[new destroy]
  permit_params :seed, :alternate_seed, :preferred_contact_method, :language_code

  member_action :send_invite, method: :get do
    redirect_to resource_path
  end

  member_action :reset, method: :get do
    redirect_to resource_path
  end

  action_item :send_invite, only: :show do
    link_to 'Send Invite', send_invite_admin_alternate_seed_path(params[:id])
  end

  action_item :reset, only: :show do
    link_to 'Reset', reset_admin_alternate_seed_path(resource)
  end

  index row_class: ->(elem) { elem.expired_class if elem.invite_expired? } do
    column :id do |participant|
      link_to participant.id, admin_participant_path(participant.id)
    end
    column :email
    column :phone_number, &:formatted_phone_number
    column :country
    column :code do |participant|
      link_to participant.code, admin_participant_path(participant.id)
    end
    column :sgm_group
    column :quota_met, &:recruitment_quota_met
    column :remind
    column 'Contact Method', &:contact_method
    column 'Consent' do |participant|
      ul do
        participant.seed_consents.each do |consent|
          li { link_to consent.id.to_s, admin_survey_response_path(consent.id) }
        end
      end
    end
    column 'Recruits' do |participant|
      ul do
        participant.recruits.each do |recruit|
          li { link_to recruit.code, admin_participant_path(recruit.id) }
        end
      end
    end
    column 'Reminders' do |participant|
      link_to participant.reminders.size, admin_participant_reminders_path(participant.id)
    end
    column :due_on
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :seed
      f.input :alternate_seed
      f.input :preferred_contact_method, as: :select, collection: [%w[Email 1], %w[Phone 2]]
      f.input :language_code, as: :select, collection: [%w[English en], %w[Vietnamese vi], %w[Swahili sw], %w[Brazilian-Portuguese pt-BR]]
    end
    f.actions
  end

  controller do
    def scoped_collection
      Participant.alternate_seeds
    end

    def send_invite
      @participant = Participant.find(params[:id])
      @participant.start_rds
      redirect_to(admin_alternate_seeds_path, notice: "RDS invite sent to #{@participant.email}")
    end

    def reset
      participant = Participant.find(params[:id])
      participant.reset
      redirect_to admin_alternate_seed_path(participant)
    end
  end
end
# rubocop:enable Metrics/BlockLength
