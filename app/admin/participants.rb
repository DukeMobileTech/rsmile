# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Participant do
  menu priority: 1
  config.per_page = [25, 50, 100, 250, 500, 1000, 2500, 5000, 10_000]
  actions :all, except: %i[new]
  permit_params :include

  collection_action :enrollment, method: :get do
    redirect_to resource_path
  end

  collection_action :participant_level, method: :get do
    redirect_to resource_path
  end

  collection_action :participant_duplicates, method: :get do
    redirect_to resource_path
  end

  collection_action :rds_candidates, method: :get do
    redirect_to resource_path
  end

  collection_action :all, method: :get do
    redirect_to resource_path
  end

  action_item :all, only: :index do
    link_to 'All Participants', all_admin_participants_path
  end

  action_item :rds_candidates, only: :index do
    link_to 'RDS Candidates', rds_candidates_admin_participants_path
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
    def enrollment
      send_file Participants::EnrollmentLogbook.new.file,
                type: 'text/xlsx', filename: "Enrollment-Logbook-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end

    def participant_level
      send_file Participants::ParticipantLevelData.new.file,
                type: 'text/csv', filename: "Participant-Level-Data-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def participant_duplicates
      Participant.find_each do |participant|
        ParticipantDuplicatesJob.perform_later(participant.id)
      end
      redirect_to admin_participants_path
    end

    def rds_candidates
      send_file Participants::RdsCandidates.new.file,
                type: 'text/xlsx', filename: "RDS-Candidates-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end

    def all
      send_file Participants::All.new.file,
                type: 'text/xlsx', filename: "All-Participants-#{Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
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
    column :include
    column :sgm_group
    column :verified
    column :verification_code
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
    column 'Accepted', &:accepted?
    column 'Mobilizer', &:mobilizer
    column 'Source', &:source
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
      row 'Contact Method' do |participant|
        participant.contact_method
      end
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
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :include
    end
    f.actions
  end
end
# rubocop:enable Metrics/BlockLength
