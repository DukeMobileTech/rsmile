ActiveAdmin.register SurveyResponse, as: 'Baseline' do
  menu label: 'Baseline Surveys'
  menu priority: 4
  config.per_page = [25, 50, 100]
  permit_params :response_uuid, :participant_id, :country, :survey_complete, :eligible, :sgm_group, :source, :language
  preserve_default_filters!
  filter :participant, collection: -> { Participant.where(id: SurveyResponse.baselines.pluck(:participant_id).uniq) }
  remove_filter :survey_uuid
  remove_filter :survey_title

  index do
    column :id
    column :response_uuid
    column :participant
    column :country
    column :survey_complete
    column :eligible
    column :sgm_group
    column :intersex
    column :gender_identity, &:gender_identity_label
    column :sexual_orientation, &:sexual_orientation_label
    column :source, &:source_label
    column :metadata
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :response_uuid
      input :participant
      input :country, as: :select, collection: %w[Brazil Kenya Vietnam]
      input :survey_complete
      input :eligible
      input :sgm_group, as: :select, collection: Participant.all_sgm_groups
      input :language, as: :select, collection: %w[en sw vi pt-BR]
      input :source, as: :select, collection: %w[0 1 2 3 4 5 6 7 8 9 10 11]
    end
    f.actions
  end

  controller do
    def scoped_collection
      SurveyResponse.baselines
    end
  end
end
