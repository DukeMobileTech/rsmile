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
    column :preferred_contact_method
    column :survey_responses do |participant|
      unless participant.survey_responses.empty?
        table_for participant.survey_responses do
          column do |response|
            link_to response.survey_title, admin_survey_response_path(response.id)
          end
        end
      end
    end
    column :created_at
    column :updated_at
    actions
  end
end
