# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Participant do
  menu priority: 1
  config.per_page = [25, 50, 100, 250, 500, 1000, 2500, 5000, 10_000]
  config.clear_action_items! # Removes the link to 'New' action
  filter :seed
  filter :code
  filter :referrer_code
  filter :sgm_group, as: :select, collection: proc { Participant::ELIGIBLE_SGM_GROUPS }
  filter :referrer_sgm_group, as: :select, collection: proc { Participant::ELIGIBLE_SGM_GROUPS }
  filter :quota_met
  filter :email
  filter :phone_number
  actions :all, except: %i[new]
  permit_params :include, :seed

  collection_action :enrollment, method: :get do
    redirect_to resource_path
  end

  collection_action :participant_level, method: :get do
    redirect_to resource_path
  end

  collection_action :participant_duplicates, method: :get do
    redirect_to resource_path
  end

  collection_action :opt_out, method: :get do
    redirect_to resource_path
  end

  action_item :enrollment, only: :index do
    link_to 'Enrollment Logbook', enrollment_admin_participants_path
  end

  action_item :participant_level, only: :index do
    link_to 'Participant Level Data', participant_level_admin_participants_path
  end

  action_item :participant_duplicates, only: :index do
    link_to 'Filter Baseline Duplicates', participant_duplicates_admin_participants_path
  end

  controller do
    skip_before_action :require_login, only: %i[opt_out]

    def enrollment
      send_file Participant.enrollment, type: 'text/xlsx',
                                        filename: "Enrollment-Logbook-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end

    def participant_level
      send_file Participant.participant_level, type: 'text/xlsx',
                                               filename: "Participant-Level-Data-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end

    def participant_duplicates
      Participant.find_each do |participant|
        ParticipantDuplicatesJob.perform_later(participant.id)
      end
      redirect_to admin_participants_path
    end

    def opt_out
      participant = Participant.find_by(code: params[:code])
      participant&.update(opt_out: true)
      render 'opt_out', layout: 'clearance'
    end
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
    column :referrer_code do |participant|
      link_to participant.referrer_code, admin_participant_path(participant.recruiter.id) if participant.recruiter
    end
    column :include
    column :sgm_group
    column :referrer_sgm_group
    column :match
    column :quota_met
    column :verified
    column :verification_code
    column :remind
    column 'Contact Method', &:contact_method
    column 'Consent' do |participant|
      ul do
        participant.consents.each do |consent|
          li { link_to consent.id.to_s, admin_survey_response_path(consent.id) }
        end
      end
    end
    column 'Contact Info' do |participant|
      ul do
        participant.contacts.each do |contact|
          li { link_to contact.id.to_s, admin_survey_response_path(contact.id) }
        end
      end
    end
    column 'Baseline' do |participant|
      ul do
        participant.baselines.each do |baseline|
          li { link_to baseline.id, admin_survey_response_path(baseline.id) }
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

  show do
    attributes_table do
      row :id
      row :email
      row :phone_number
      row :country
      row :self_generated_id
      row :code
      row :sgm_group
      row :verified
      row :verification_code
      row :include
      row :created_at
      row :updated_at
      row 'Contact Method', &:contact_method
      row 'Consent' do |participant|
        ul do
          participant.consents.each do |consent|
            li { link_to consent.id.to_s, admin_survey_response_path(consent.id) }
          end
        end
      end
      row 'Contact Info' do |participant|
        ul do
          participant.contacts.each do |contact|
            li { link_to contact.id.to_s, admin_survey_response_path(contact.id) }
          end
        end
      end
      row 'Baseline' do |participant|
        ul do
          participant.baselines.each do |baseline|
            li { link_to baseline.id, admin_survey_response_path(baseline.id) }
          end
        end
      end
      row 'Reminders' do |participant|
        link_to participant.reminders.size, admin_participant_reminders_path(participant.id)
      end
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :include
      f.input :seed
    end
    f.actions
  end
end
# rubocop:enable Metrics/BlockLength
