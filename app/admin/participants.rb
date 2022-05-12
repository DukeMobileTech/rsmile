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
end
