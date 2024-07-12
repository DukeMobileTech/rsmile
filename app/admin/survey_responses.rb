ActiveAdmin.register SurveyResponse do
  menu priority: 8
  config.per_page = [25, 50, 100]
  permit_params :duplicate

  collection_action :baseline_metadata, method: :get do
    redirect_to resource_path
  end

  action_item :baseline_metadata, only: :index do
    link_to 'Update Metadata', baseline_metadata_admin_survey_responses_path
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :duplicate
    end
    f.actions
  end

  controller do
    def baseline_metadata
      surveys = SurveyResponse.baselines
      surveys.each do |survey|
        SurveyMetadataJob.perform_later(survey.id)
      end
      redirect_to admin_survey_responses_path
    end
  end
end
