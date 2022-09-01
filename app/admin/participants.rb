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
    column :name
    column :code
    column :referrer_code
    column :sgm_group
    column :referrer_sgm_group
    column 'RDS ID', :rds_id
    column 'Surveys' do |participant|
      ul do
        participant.survey_responses.each do |survey|
          li { link_to survey.id, admin_survey_response_path(survey.id) }
        end
      end
    end
    column :match
    column :quota
    column :created_at
    column :updated_at
    actions
  end
end
