# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Participant, as: 'Seed' do
  menu label: 'RDS Seeds'
  menu priority: 1

  member_action :send_invite, method: :get do
    redirect_to resource_path
  end

  action_item :send_invite, only: :show do
    link_to 'Send Invite', send_invite_admin_seed_path(params[:id])
  end

  index do
    selectable_column
    column :id do |participant|
      link_to participant.id, admin_participant_path(participant.id)
    end
    column :email
    column :phone_number
    column :country
    column :self_generated_id
    column :seed
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
    column :created_at
    column :updated_at
    actions
  end

  controller do
    def scoped_collection
      Participant.seeds
    end

    def send_invite
      @participant = Participant.find(params[:id])
      @participant.start_rds
      redirect_to(admin_seeds_path, notice: "RDS invite sent to #{@participant.email}")
    end
  end
end
# rubocop:enable Metrics/BlockLength
