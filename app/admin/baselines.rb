ActiveAdmin.register SurveyResponse, as: 'Baseline' do
  menu label: 'Baseline Surveys'
  menu priority: 4
  config.per_page = [50, 100, 250, 500, 1000, 2500, 5000, 10_000]
  permit_params :response_uuid, :participant_id, :country, :survey_complete, :eligible, :sgm_group, :source, :language
  preserve_default_filters!
  filter :participant, collection: -> { Participant.where(id: SurveyResponse.baselines.pluck(:participant_id).uniq) }
  remove_filter :survey_uuid
  remove_filter :survey_title

  index row_class: ->(elem) { elem.mismatch_class if elem.sgm_group_mismatch? } do
    column :id
    column 'Response', :response_uuid
    column :participant, sortable: 'participant_id'
    column :country
    column 'Complete', :survey_complete
    column :intersex, sortable: "metadata->'intersex'"
    column 'Identity', :gender_identity, sortable: "metadata->'gender'", &:gender_identity_label
    column 'Attraction', :sexual_attraction, sortable: "metadata->'sexual_attraction'", &:sexual_attraction_label
    column 'Attraction Eligibility', :attraction_eligibility, sortable: "metadata->'attraction_eligibility'"
    column 'Orientation', :sexual_orientation, sortable: "metadata->'sexual_orientation'", &:sexual_orientation_label
    column :sgm_group, sortable: "metadata->'sgm_group'"
    column :attraction_sgm_group, sortable: "metadata->'attraction_sgm_group'"
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
