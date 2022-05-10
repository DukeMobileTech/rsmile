ActiveAdmin.register SurveyResponse, as: 'Baseline' do
  menu label: 'Baseline Surveys'
  menu priority: 4
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
    column :source, &:source_label
    column :language
    column :created_at
    actions
  end

  controller do
    def scoped_collection
      SurveyResponse.baselines
    end
  end
end
