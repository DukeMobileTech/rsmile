ActiveAdmin.register Participant do
  menu priority: 1
  config.per_page = [25, 50, 100]

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :index do
    link_to 'Enrollment Logbook', download_admin_participants_path
  end

  controller do
    def download
      send_file Participant.enrollment, type: 'text/xlsx',
                                        filename: "Enrollment-Logbook-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
    end
  end

  index do
    selectable_column
    column :id
    column :email
    column :phone_number
    column :country
    column :self_generated_id
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
    column :created_at
    column :updated_at
    actions
  end
end
