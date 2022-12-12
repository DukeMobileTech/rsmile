ActiveAdmin.register Participant do
  menu priority: 1
  config.per_page = [25, 50, 100]
  config.clear_action_items! # Removes the link to 'New' action
  filter :seed
  filter :code
  filter :referrer_code
  filter :sgm_group, as: :select, collection: proc { Participant.pilot_sgm_groups }
  filter :referrer_sgm_group, as: :select, collection: proc { Participant.pilot_sgm_groups }
  filter :raffle_quota_met
  filter :enter_raffle

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :index do
    link_to 'Enrollment Logbook', download_admin_participants_path
  end

  controller do
    def download
      send_file Participant.enrollment, type: 'text/xlsx',
                                        filename: "Enrollment-Logbook-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end
  end

  index do
    column :id
    column :name
    column :seed
    column 'Seed Id', :seed_id
    column :code
    column :referrer_code
    column :sgm_group
    column :referrer_sgm_group
    column :match
    column 'Surveys' do |participant|
      ul do
        participant.survey_responses.each do |survey|
          li { link_to "#{survey.id}: #{survey.survey_title}", admin_survey_response_path(survey.id) }
        end
      end
    end
    column :enter_raffle
    column 'Raffles' do |participant|
      link_to participant.raffles.size, admin_participant_raffles_path(participant.id)
    end
    column :raffle_quota_met
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
    column 'Contact', &:contact_method
    column 'Possible Duplicates', &:duplicates
    column 'State', :country
    column :created_at
    actions
  end
end
