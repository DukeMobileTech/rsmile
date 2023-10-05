ActiveAdmin.register ResponseExport do # rubocop:disable Metrics/BlockLength
  actions :all, except: %i[edit]
  permit_params :survey_id, :country

  index do # rubocop:disable Metrics/BlockLength
    selectable_column
    column :id
    column 'Survey Id', :survey_id
    column :status
    column :percent_complete
    column 'Progress Id', :progress_id
    column 'File Id', :file_id
    column 'Files', :file_path do |response_export|
      div do
        if Dir["#{response_export.file_path}/*.csv"][0]
          link_to Dir["#{response_export.file_path}/*.csv"][0].split('/').last,
                  controller: 'response_exports',
                  action: 'download_file',
                  id: response_export.id,
                  name: Dir["#{response_export.file_path}/*.csv"][0].split('/').last
        end
      end
      div do
        if Dir["#{response_export.file_path}/*.csv"][1]
          link_to Dir["#{response_export.file_path}/*.csv"][1].split('/').last,
                  controller: 'response_exports',
                  action: 'download_file',
                  id: response_export.id,
                  name: Dir["#{response_export.file_path}/*.csv"][1].split('/').last
        end
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :survey_id, as: :select, collection: SurveyResponse.baselines.pluck(:survey_uuid).compact.uniq
      f.input :country, as: :select, collection: %w[Brazil Kenya Vietnam]
    end
    f.actions
  end

  member_action :download_file do
    response_export = ResponseExport.find(params[:id])
    file = File.new("#{response_export.file_path}/#{params[:name]}")
    send_file file, type: 'text/csv', filename: params[:name]
  end
end
