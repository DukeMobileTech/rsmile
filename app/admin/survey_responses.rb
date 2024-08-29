ActiveAdmin.register SurveyResponse do
  menu priority: 11
  config.per_page = [25, 50, 100]
  permit_params :duplicate

  collection_action :baseline_metadata, method: :get do
    redirect_to resource_path
  end

  action_item :baseline_metadata, only: :index do
    link_to 'Update Metadata', baseline_metadata_admin_survey_responses_path
  end

  index do
    column :id
    column :participant_id
    column :response_uuid do |sr|
      link_to sr.response_uuid, "#{Rails.application.credentials.config[:QUALTRICS_RESPONSE_VIEW_BASE_URL]}RID=#{sr.response_uuid}&SID=#{sr.survey_uuid}", { target: '_blank', rel: 'noopener' }
    end
    column :survey_uuid
    column :survey_title
    column :survey_complete
    column :country
    column :duplicate
    column :created_at
    column :updated_at
    actions
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
